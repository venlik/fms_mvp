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

  @protected
  Future<File> dataPath(StorageGroup gp);
  @protected
  Future<Directory> documentsDirectory();

  Future<File> saveDocument({required String name, required List<int> bytes});

  // ── readData ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> readData(StorageGroup group) async {
    final file = await dataPath(group);

    // Recover from a partial write before reading.
    await _recoverIfNeeded(file);

    if (!await file.exists()) return {};
    if (await file.length() == 0) return {};

    final raw = await file.readAsString();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw StorageFailure(
          'Expected a JSON object in ${file.path}, '
          'got ${decoded.runtimeType}',
        );
      }
      return decoded.cast<String, dynamic>();
    } on FormatException catch (e) {
      throw StorageFailure('Corrupt JSON in ${file.path}: $e');
    }
  }

  // ── writeData ────────────────────────────────────────────────────

  Future<void> writeData(StorageGroup group, Map<String, dynamic> data) async {
    final original = await dataPath(group);

    // Recover from a partial write before write.
    await _recoverIfNeeded(original);
    await original.parent.create(recursive: true);

    final path = original.path;
    final tmp = File('$path.tmp');
    final backup = File('$path.old');

    // Clean up any stale artifacts from a previous crash.
    if (await backup.exists()) await backup.delete();
    if (await tmp.exists()) await tmp.delete();

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
          'ROLLBACK: originalBackedUp=$originalBackedUp newInstalled=$newInstalled '
          'originalExists=${original.existsSync()} backupExists=${backup.existsSync()} '
          'tmpExists=${tmp.existsSync()}',
        );
        return true;
      }());

      if (originalBackedUp && !newInstalled) {
        if (!await original.exists() && await backup.exists()) {
          await backup.rename(path);
        }
      }
      if (await tmp.exists()) {
        await tmp.delete();
      }
      rethrow;
    }
  }

  // ── recovery ─────────────────────────────────────────────────────

  /// Recovers from a partial-write state before any read or write.
  ///
  /// Policy: when both `.old` and `.tmp` exist and the primary is
  /// missing, restore `.old` (known-good) and discard `.tmp` (never
  /// confirmed). Losing the last write is safer than losing the
  /// ledger.
  Future<void> _recoverIfNeeded(File file) async {
    final path = file.path;
    final tmp = File('$path.tmp');
    final backup = File('$path.old');

    final hasPrimary = await file.exists();
    final hasBackup = await backup.exists();
    final hasTmp = await tmp.exists();

    if (hasPrimary) {
      // Happy path. Clean up any leftover tmp/backup.
      if (hasBackup) await backup.delete();
      if (hasTmp) await tmp.delete();
      return;
    }

    if (hasBackup && hasTmp) {
      // Crash between rename-to-backup and install-tmp.
      // Restore .old (known-good), discard .tmp (unconfirmed).
      await backup.rename(path);
      await tmp.delete();
      return;
    }

    if (hasBackup && !hasTmp) {
      // Crash after rename-to-backup, before tmp was written.
      // Restore .old.
      await backup.rename(path);
      return;
    }

    if (hasTmp && !hasBackup) {
      // Crash during tmp write. No backup to restore.
      // Discard tmp — nothing was ever committed.
      await tmp.delete();
      return;
    }

    // No primary, no backup, no tmp. Fresh install. Nothing to do.
  }
}
