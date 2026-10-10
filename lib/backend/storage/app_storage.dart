import 'dart:convert';
import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';

abstract class Storage {
  Future<File> dataPath(StorageGroup gp);

  Future<Directory> documentsDirectory();

  Future<Map<String, dynamic>> readData(StorageGroup group) async {
    var file = await dataPath(group);
    if (!file.existsSync()) {
      final originalPath = file.path;
      file = File('$originalPath.tmp');
    }

    if (!await file.exists()) return {};

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
    final file = await dataPath(group);
    await file.parent.create(recursive: true);

    final json = const JsonEncoder.withIndent('  ').convert(data);

    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(json, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }
}
