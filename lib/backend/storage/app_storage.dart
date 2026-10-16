import 'dart:convert';
import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:meta/meta.dart';

abstract class Storage {
  /// Test hook. Called after the old file has been renamed to `.old`
  /// and before the new file is installed at the primary path. Tests
  /// use this to inject a failure and exercise the rollback path.
  ///
  /// Production code never sets this. It's null by default.
  @visibleForTesting
  Future<void> Function()? beforeInstall;

  /// Refuse to load files larger than this. Guards against OOM on a
  /// corrupted or hostile filesystem. 64 MiB is far above any sane
  /// ledger size.
  @protected
  int get maxDataBytes => 64 * 1024 * 1024;

  @protected
  Future<File> dataPath(StorageGroup gp);

  @protected
  Future<Directory> documentsDirectory();

  Future<File> saveDocument({required String name, required List<int> bytes});

  // ── readData ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> readData(StorageGroup group) async {
    final primary = await dataPath(group);

    // 1. Try the primary. If it is missing or unreadable, attempt
    //    recovery from siblings BEFORE deciding what to return.
    final primaryResult = await _tryRead(primary);
    if (primaryResult is _Ok) {
      // Only now is it safe to discard recovery artifacts.
      await _cleanupSiblings(primary);
      return primaryResult.value;
    }

    // 2. Primary missing or corrupt. Try to recover from `.old`.
    final backup = File('${primary.path}.old');
    if (await backup.exists()) {
      final backupResult = await _tryRead(backup);
      if (backupResult is _Ok) {
        // Promote the backup back to primary so the next read is
        // on the happy path.
        await backup.rename(primary.path);
        await _deleteIfExists(File('${primary.path}.tmp'));
        return backupResult.value;
      }
      // Backup is also corrupt. Fall through — do not silently
      // return {}; surface the failure below.
    }

    // 3. Primary is missing and no usable backup exists. Distinguish
    //    "never written" (fresh install) from "damaged".
    final tmp = File('${primary.path}.tmp');
    final primaryExists = await primary.exists();
    final backupExists = await backup.exists();
    final tmpExists = await tmp.exists();

    if (!primaryExists && !backupExists && !tmpExists) {
      // Genuinely fresh. Safe to return an empty ledger.
      return <String, dynamic>{};
    }

    // 4. Something is on disk but nothing is readable. This is
    //    data loss / corruption — never pretend it's empty.
    throw StorageFailure(
      'Unrecoverable storage state for ${primary.path}: '
      'primary=${_describe(primaryResult)} '
      'primaryExists=$primaryExists '
      'backupExists=$backupExists '
      'tmpExists=$tmpExists',
    );
  }

  // ── writeData ───────────────────────────────────────────────────────

  Future<void> writeData(StorageGroup group, Map<String, dynamic> data) async {
    final original = await dataPath(group);

    // Recover from a partial write before write. We do NOT delete
    // a valid primary here — recovery only promotes a backup when
    // the primary is missing or unreadable.
    await _recoverBeforeWrite(original);

    await original.parent.create(recursive: true);

    final path = original.path;
    final tmp = File('$path.tmp');
    final backup = File('$path.old');

    // Clean up any stale artifacts from a previous crash.
    await _deleteIfExists(backup);
    await _deleteIfExists(tmp);

    final json = const JsonEncoder.withIndent('  ').convert(data);

    var originalBackedUp = false;
    var newInstalled = false;

    try {
      // 1. Write new data to tmp.
      await tmp.writeAsString(json, flush: true);

      // 2. If original exists, move it aside.
      if (await original.exists()) {
        await original.rename(backup.path);
        originalBackedUp = true;
      }

      // 3. Test hook — inject failure here for rollback tests.
      await beforeInstall?.call();

      // 4. Move tmp into place.
      await tmp.rename(path);
      newInstalled = true;

      // 5. Delete the backup now that the new file is in place.
      if (originalBackedUp) {
        await backup.delete();
      }
    } catch (_) {
      assert(() {
        // ignore: avoid_print
        print(
          'ROLLBACK: originalBackedUp=$originalBackedUp '
          'newInstalled=$newInstalled '
          'originalExists=${original.existsSync()} '
          'backupExists=${backup.existsSync()} '
          'tmpExists=${tmp.existsSync()}',
        );
        return true;
      }());

      if (originalBackedUp && !newInstalled) {
        if (!await original.exists() && await backup.exists()) {
          await backup.rename(path);
        }
      }
      await _deleteIfExists(tmp);
      rethrow;
    }
  }

  // ── internals ───────────────────────────────────────────────────────

  /// Attempts to read and parse [file] as a JSON object.
  ///
  /// Returns [_Ok] on success. Returns [_Missing] if the file does
  /// not exist. Returns [_Bad] (with a human-readable reason) if the
  /// file exists but cannot be parsed as a non-empty JSON object.
  ///
  /// Crucially, this does NOT mutate the filesystem.
  Future<_ReadResult> _tryRead(File file) async {
    if (!await file.exists()) return const _Missing();

    final length = await file.length();
    if (length == 0) {
      // A zero-byte file is a truncated write, not an empty ledger.
      return const _Bad('zero-byte file');
    }
    if (length > maxDataBytes) {
      return _Bad('file exceeds $maxDataBytes bytes ($length)');
    }

    late final String raw;
    try {
      raw = await file.readAsString();
    } on FileSystemException catch (e) {
      return _Bad('unreadable: $e');
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      return _Bad('invalid JSON: $e');
    }

    if (decoded is! Map) {
      return _Bad('expected JSON object, got ${decoded.runtimeType}');
    }

    return _Ok(decoded.cast<String, dynamic>());
  }

  /// Recovery used before a write. Unlike the read path, we only
  /// promote a backup when the primary is missing — we never
  /// clobber a readable primary with a possibly-stale backup.
  Future<void> _recoverBeforeWrite(File primary) async {
    if (await primary.exists()) {
      // Primary is present. Leave it alone; writeData will back it up.
      // Still clean up orphaned tmp (never committed).
      await _deleteIfExists(File('${primary.path}.tmp'));
      return;
    }

    final tmp = File('${primary.path}.tmp');
    final backup = File('${primary.path}.old');

    final hasBackup = await backup.exists();
    final hasTmp = await tmp.exists();

    if (hasBackup && hasTmp) {
      // Crash between rename-to-backup and install-tmp.
      // Restore .old (known-good), discard .tmp (unconfirmed).
      await backup.rename(primary.path);
      await tmp.delete();
      return;
    }

    if (hasBackup && !hasTmp) {
      // Crash after rename-to-backup, before tmp was written.
      await backup.rename(primary.path);
      return;
    }

    if (hasTmp && !hasBackup) {
      // Crash during tmp write. No backup to restore.
      await tmp.delete();
      return;
    }

    // Fresh install. Nothing to do.
  }

  /// Removes `.tmp` and `.old` siblings. Only called once the
  /// primary has been successfully parsed.
  Future<void> _cleanupSiblings(File primary) async {
    await _deleteIfExists(File('${primary.path}.tmp'));
    await _deleteIfExists(File('${primary.path}.old'));
  }

  Future<void> _deleteIfExists(File f) async {
    if (await f.exists()) await f.delete();
  }

  String _describe(_ReadResult r) => switch (r) {
        _Ok() => 'ok',
        _Missing() => 'missing',
        _Bad(:final reason) => 'corrupt ($reason)',
      };
}

// ── read result types ─────────────────────────────────────────────────

sealed class _ReadResult {
  const _ReadResult();
}

final class _Ok extends _ReadResult {
  const _Ok(this.value);
  final Map<String, dynamic> value;
}

final class _Missing extends _ReadResult {
  const _Missing();
}

final class _Bad extends _ReadResult {
  const _Bad(this.reason);
  final String reason;
}