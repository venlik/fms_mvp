import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:path_provider/path_provider.dart';

class FlutterStorage extends Storage {
  static final FlutterStorage _instance = FlutterStorage._internal();
  factory FlutterStorage() => _instance;
  FlutterStorage._internal();

  @override
  Future<File> dataPath(StorageGroup gp) async {
    final dir = await getApplicationSupportDirectory();
    final file = _respectiveFile(gp);
    return File('${dir.path}/$file');
  }

  String _respectiveFile(StorageGroup gp) => gp.file;

  // ── Documents ───────────────────────────────────────────────────

  @override
  Future<Directory> documentsDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  @override
  Future<File> saveDocument({
    required String name,
    required List<int> bytes,
  }) async {
    final dir = await documentsDirectory();
    final safeName = _sanitizeFilename(name);
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _sanitizeFilename(String input) {
    final base = input.split(RegExp(r'[/\\]')).last;
    final cleaned = base.replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_');
    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'document';
    }
    return cleaned;
  }
}
