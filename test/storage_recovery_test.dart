// test/storage_recovery_test.dart
//
// Tests for Storage's read/write/recover behavior.
//
// The Storage contract:
//   • readData returns {} for missing/empty files (fresh install).
//   • readData throws StorageFailure for corrupt JSON.
//   • readData never sees a partial-write state — it recovers first.
//   • writeData is atomic-ish: rollback on failure, no stale backup.
//
// Recovery policy: when both .old and .tmp exist, restore .old and
// discard .tmp. The interrupted write was never confirmed, and the
// previous state is known-good.

import 'dart:convert';
import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Storage implementation that writes to a temp directory.
/// Mirrors the production file layout (path, .tmp, .old) so recovery
/// behavior can be exercised directly.
class TestStorage extends Storage {
  final Directory root;

  TestStorage(this.root);

  @override
  Future<File> dataPath(StorageGroup gp) async =>
      File('${root.path}/${gp.file}');

  @override
  Future<Directory> documentsDirectory() async => root;

  @override
  Future<File> saveDocument({
    required String name,
    required List<int> bytes,
  }) async {
    final file = File('${root.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

void main() {
  late Directory tmp;
  late TestStorage storage;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('fs_storage_test_');
    storage = TestStorage(tmp);
  });

  tearDown(() {
    if (tmp.existsSync()) {
      tmp.deleteSync(recursive: true);
    }
  });

  File dataFile(StorageGroup gp) => File('${tmp.path}/${gp.file}');
  File backupFile(StorageGroup gp) => File('${tmp.path}/${gp.file}.old');
  File tmpFile(StorageGroup gp) => File('${tmp.path}/${gp.file}.tmp');

  // ── readData: missing and empty ──────────────────────────────────

  group('readData — missing and empty', () {
    test('returns {} when the file does not exist', () async {
      final result = await storage.readData(StorageGroup.items);
      expect(result, isEmpty);
    });

    test('returns {} when the file exists but is empty', () async {
      await dataFile(StorageGroup.items).writeAsString('');
      final result = await storage.readData(StorageGroup.items);
      expect(result, isEmpty);
    });

    test('returns parsed map for valid JSON', () async {
      await dataFile(StorageGroup.items).writeAsString(
        jsonEncode({
          'items': [1, 2, 3],
        }),
      );
      final result = await storage.readData(StorageGroup.items);
      expect(result, {
        'items': [1, 2, 3],
      });
    });
  });

  // ── readData: corruption ─────────────────────────────────────────

  group('readData — corruption', () {
    test('throws StorageFailure for invalid JSON', () async {
      await dataFile(StorageGroup.items).writeAsString('{not json}');
      expect(
        () => storage.readData(StorageGroup.items),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('throws StorageFailure for JSON that is not an object', () async {
      await dataFile(StorageGroup.items).writeAsString('[1, 2, 3]');
      expect(
        () => storage.readData(StorageGroup.items),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('throws StorageFailure with the file path in the message', () async {
      await dataFile(StorageGroup.items).writeAsString('{not json}');
      try {
        await storage.readData(StorageGroup.items);
        fail('expected StorageFailure');
      } on StorageFailure catch (e) {
        expect(e.message, contains(StorageGroup.items.file));
      }
    });
  });

  // ── readData: partial-write recovery ─────────────────────────────

  group('readData — recovery from partial writes', () {
    test(
      'when .old and .tmp both exist and no primary, restores .old and discards .tmp',
      () async {
        await backupFile(StorageGroup.items).writeAsString(
          jsonEncode({'old': true}),
        );
        await tmpFile(StorageGroup.items).writeAsString(
          jsonEncode({'new': true}),
        );
        // primary does not exist

        final result = await storage.readData(StorageGroup.items);

        expect(result, {'old': true});
        expect(await dataFile(StorageGroup.items).exists(), isTrue);
        expect(await tmpFile(StorageGroup.items).exists(), isFalse);
        expect(await backupFile(StorageGroup.items).exists(), isFalse);
      },
    );

    test('when only .old exists, restores it', () async {
      await backupFile(StorageGroup.items).writeAsString(
        jsonEncode({'old': true}),
      );

      final result = await storage.readData(StorageGroup.items);

      expect(result, {'old': true});
      expect(await dataFile(StorageGroup.items).exists(), isTrue);
      expect(await backupFile(StorageGroup.items).exists(), isFalse);
    });

    test('when only .tmp exists, discards it and returns {}', () async {
      await tmpFile(StorageGroup.items).writeAsString(
        jsonEncode({'new': true}),
      );

      final result = await storage.readData(StorageGroup.items);

      expect(result, isEmpty);
      expect(await tmpFile(StorageGroup.items).exists(), isFalse);
      expect(await dataFile(StorageGroup.items).exists(), isFalse);
    });

    test(
      'when primary exists with stale .old and .tmp, primary wins and stale files are cleaned',
      () async {
        await dataFile(StorageGroup.items).writeAsString(
          jsonEncode({'primary': true}),
        );
        await backupFile(StorageGroup.items).writeAsString(
          jsonEncode({'old': true}),
        );
        await tmpFile(StorageGroup.items).writeAsString(
          jsonEncode({'new': true}),
        );

        final result = await storage.readData(StorageGroup.items);

        expect(result, {'primary': true});
        expect(await backupFile(StorageGroup.items).exists(), isFalse);
        expect(await tmpFile(StorageGroup.items).exists(), isFalse);
      },
    );
  });

  // ── writeData: happy path ────────────────────────────────────────

  group('writeData — happy path', () {
    test('writes to a fresh path (no prior file)', () async {
      await storage.writeData(StorageGroup.items, {'a': 1});

      final file = dataFile(StorageGroup.items);
      expect(await file.exists(), isTrue);
      expect(jsonDecode(await file.readAsString()), {'a': 1});
      expect(await tmpFile(StorageGroup.items).exists(), isFalse);
      expect(await backupFile(StorageGroup.items).exists(), isFalse);
    });

    test('overwrites an existing file', () async {
      await storage.writeData(StorageGroup.items, {'a': 1});
      await storage.writeData(StorageGroup.items, {'a': 2});

      final file = dataFile(StorageGroup.items);
      expect(jsonDecode(await file.readAsString()), {'a': 2});
      expect(await backupFile(StorageGroup.items).exists(), isFalse);
      expect(await tmpFile(StorageGroup.items).exists(), isFalse);
    });

    test('cleans up stale .old before writing', () async {
      await backupFile(StorageGroup.items).writeAsString('stale');

      await storage.writeData(StorageGroup.items, {'a': 1});

      expect(await backupFile(StorageGroup.items).exists(), isFalse);
      expect(
        jsonDecode(await dataFile(StorageGroup.items).readAsString()),
        {'a': 1},
      );
    });

    test('cleans up stale .tmp before writing', () async {
      await tmpFile(StorageGroup.items).writeAsString('stale');

      await storage.writeData(StorageGroup.items, {'a': 1});

      expect(await tmpFile(StorageGroup.items).exists(), isFalse);
      expect(
        jsonDecode(await dataFile(StorageGroup.items).readAsString()),
        {'a': 1},
      );
    });

    test('round-trip: write then read returns the written map', () async {
      final payload = {
        'items': [
          {'id': 1, 'name': 'Widget'},
          {'id': 2, 'name': 'Gadget'},
        ],
      };
      await storage.writeData(StorageGroup.items, payload);

      final result = await storage.readData(StorageGroup.items);
      expect(result, payload);
    });
  });

  // ── writeData: crash-window simulation ───────────────────────────

  group('writeData — crash-window recovery on next read', () {
    test(
      'recovery after simulated crash between rename and install',
      () async {
        // Establish a known-good state.
        await storage.writeData(StorageGroup.items, {'version': 'old'});

        // Simulate a crash: original renamed to .old, tmp written,
        // but tmp.rename(path) never happened.
        final primary = dataFile(StorageGroup.items);
        final backup = backupFile(StorageGroup.items);
        final tmp = tmpFile(StorageGroup.items);

        await primary.rename(backup.path);
        await tmp.writeAsString(jsonEncode({'version': 'new'}));

        // Next read recovers.
        final result = await storage.readData(StorageGroup.items);

        expect(result, {'version': 'old'});
        expect(await primary.exists(), isTrue);
        expect(await backup.exists(), isFalse);
        expect(await tmp.exists(), isFalse);
      },
    );

    test('recovery then write: subsequent write succeeds', () async {
      // Simulate crash window.
      await backupFile(StorageGroup.items).writeAsString(
        jsonEncode({'version': 'old'}),
      );
      await tmpFile(StorageGroup.items).writeAsString(
        jsonEncode({'version': 'new'}),
      );

      // First read recovers.
      await storage.readData(StorageGroup.items);

      // Now write should succeed without hitting the "existing backup" guard.
      await storage.writeData(StorageGroup.items, {'version': 'next'});

      final result = await storage.readData(StorageGroup.items);
      expect(result, {'version': 'next'});
    });
  });

  // ── writeData: rollback on failure ───────────────────────────────

  group('writeData — rollback on failure', () {
    test('restores .old when install step fails', () async {
      // Establish known-good state.
      await storage.writeData(StorageGroup.items, {'version': 'old'});

      // Inject a failure at the exact point after .old was created,
      // before the new file was installed. Storage exposes this hook
      // (see the @visibleForTesting field `beforeInstall`) so the
      // rollback code path can be exercised without faking a
      // filesystem failure.
      storage.beforeInstall = () async {
        throw FileSystemException('Simulated failure during install');
      };

      await expectLater(
        () => storage.writeData(StorageGroup.items, {'version': 'new'}),
        throwsA(isA<FileSystemException>()),
      );

      // Primary should hold the old data again.
      final primary = dataFile(StorageGroup.items);
      expect(await primary.exists(), isTrue);
      expect(jsonDecode(await primary.readAsString()), {'version': 'old'});

      // No leftover files.
      expect(await backupFile(StorageGroup.items).exists(), isFalse);
      expect(await tmpFile(StorageGroup.items).exists(), isFalse);

      // Clear the hook so subsequent tests are unaffected.
      storage.beforeInstall = null;
    });
  });

  // ── cross-group isolation ────────────────────────────────────────

  group('cross-group isolation', () {
    test('writing one group does not affect another', () async {
      await storage.writeData(StorageGroup.items, {'a': 1});
      await storage.writeData(StorageGroup.customers, {'b': 2});

      expect(await storage.readData(StorageGroup.items), {'a': 1});
      expect(await storage.readData(StorageGroup.customers), {'b': 2});
    });

    test('recovery in one group does not touch another', () async {
      await storage.writeData(StorageGroup.items, {'a': 1});

      // Simulate crash window in customers only.
      await backupFile(StorageGroup.customers).writeAsString(
        jsonEncode({'stale': true}),
      );

      final items = await storage.readData(StorageGroup.items);
      final customers = await storage.readData(StorageGroup.customers);

      expect(items, {'a': 1});
      expect(customers, {'stale': true});
    });
  });

  // ── readData: idempotent recovery ────────────────────────────────

  group('recovery is idempotent', () {
    test('running recovery twice yields the same result', () async {
      await backupFile(StorageGroup.items).writeAsString(
        jsonEncode({'old': true}),
      );

      final first = await storage.readData(StorageGroup.items);
      final second = await storage.readData(StorageGroup.items);

      expect(first, {'old': true});
      expect(second, {'old': true});
    });

    test('reading a clean file twice leaves it unchanged', () async {
      await storage.writeData(StorageGroup.items, {'a': 1});

      final first = await storage.readData(StorageGroup.items);
      final second = await storage.readData(StorageGroup.items);

      expect(first, {'a': 1});
      expect(second, {'a': 1});
      expect(await dataFile(StorageGroup.items).exists(), isTrue);
      expect(await backupFile(StorageGroup.items).exists(), isFalse);
      expect(await tmpFile(StorageGroup.items).exists(), isFalse);
    });
  });
}