import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:path_provider/path_provider.dart';

class FlutterStorage extends Storage {
 final Directory _baseDir;
  FlutterStorage._(this._baseDir);

  static Future<FlutterStorage> create() async {
    final dir = await getApplicationSupportDirectory();
    return FlutterStorage._(dir);
  }

  @override
  Future<File> dataPath(StorageGroup gp) async {
    return File('${_baseDir.path}/${gp.file}');
  }

  // ── Documents ───────────────────────────────────────────────────

  @override
  Future<Directory> documentsDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {
      // Some sandboxes can't resolve a downloads dir. Fall through
      // to app documents, which is always available.
    }
    return getApplicationDocumentsDirectory();
  }

  @override
  Future<File> saveDocument({
    required String name,
    required List<int> bytes,
  }) async {
    final dir = await documentsDirectory();
    await dir.create(recursive: true);
    final safeName = _sanitizeFilename(name);
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _sanitizeFilename(String input) {
    final base = input.split(RegExp(r'[/\\]')).last;
    final cleaned = base
        .replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_')
        .trim();
    if (cleaned.isEmpty || RegExp(r'^\.+$').hasMatch(cleaned)) {
      return 'document';
    }
    return cleaned;
  }
}