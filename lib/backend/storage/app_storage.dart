import 'dart:convert';
import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';

abstract class Storage {
  Future<File> dataPath(StorageGroup gp);

  Future<Directory> documentsDirectory();

  Future<Map<String, dynamic>> readData(StorageGroup group) async {
    var file = await dataPath(group);

    if (!await file.exists()) throw NotFound("${file.path} not found");

    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.cast<String, Object?>();
    } catch (_) {
      return {};
    }
  }

  Future<File> saveDocument({required String name, required List<int> bytes});

  Future<void> writeData(StorageGroup group, Map<String, dynamic> data) async {
    final original = await dataPath(group);
    await original.parent.create(recursive: true);

    final path = original.path;
    final tmp = File('$path.tmp');
    final backup = File('$path.old');

    final json = const JsonEncoder.withIndent('  ').convert(data);

    var originalBackedUp = false;
    var newInstalled = false;

    try {
      await tmp.writeAsString(json, flush: true);

      if (await original.exists()) {
        // prevent silently overwriting an existing recovery backup.
        if (await backup.exists()) {
          throw FileSystemException(
            'Existing backup requires recovery',
            backup.path,
          );
        }

        await original.rename(backup.path);
        originalBackedUp = true;
      }

      await tmp.rename(path);
      newInstalled = true;

      if (originalBackedUp) {
        await backup.delete();
      }
    } catch (_) {
      if (originalBackedUp && !newInstalled) {
        if (!await original.exists() && await backup.exists()) {
          await backup.rename(path);
        }
      }
      rethrow;
    }
  }
}
