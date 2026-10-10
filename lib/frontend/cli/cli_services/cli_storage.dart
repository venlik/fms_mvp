import 'dart:io';

import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

/// Storage implementation for CLI use. Reads directory locations from
/// the environment at construction time.
///
/// Required environment variables:
///   APP_DIR       — root for structured data (config, counters, JSON)
///   DOCS_DIR      — where generated PDFs are written
///   DOWNLOAD_DIR  — where imports live; where exports may be offered
///
/// All three must point at existing directories. Missing or invalid
/// values fail at construction, not at first use.
class CLIStorage extends Storage {

  final Directory appDir;
  final Directory docsDir;
  final Directory downloadsDir;

  CLIStorage._(this.appDir, this.docsDir, this.downloadsDir);

  /// Builds a [CLIStorage] from [Platform.environment] (or the
  /// provided [env], for tests). Throws [StateError] if any required
  /// variable is missing or points at a non-existent directory.
  factory CLIStorage.fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    return CLIStorage._(
      _requireDir(e, 'APP_DIR'),
      _requireDir(e, 'DOCS_DIR'),
      _requireDir(e, 'DOWNLOAD_DIR'),
    );
  }

  static Directory _requireDir(Map<String, String> env, String key) {
    final value = env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    final dir = Directory(value);
    if (!dir.existsSync()) {
      throw StateError('$key points to a non-existent directory: $value');
    }
    return dir;
  }

  // ── Structured data ──────────────────────────────────────────────

  @override
  Future<File> dataPath(StorageGroup gp) async {
    final file = _respectiveFile(gp);
    return File('${appDir.path}/$file');
  }

  String _respectiveFile(StorageGroup gp) => gp.file;
 
  // ── Documents ────────────────────────────────────────────────────

  @override
  Future<Directory> documentsDirectory() async => docsDir;

  @override
  Future<File> saveDocument({
    required String name,
    required List<int> bytes,
  }) async {
    final safeName = _sanitizeFilename(name);
    final file = File('${docsDir.path}/$safeName');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ── Downloads (for CLI tools that import/export) ─────────────────

  Directory get downloadsDirectory => downloadsDir;

  // ── Helpers ──────────────────────────────────────────────────────

  String _sanitizeFilename(String input) {
    final base = input.split(RegExp(r'[/\\]')).last;
    final cleaned = base.replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_');
    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'document';
    }
    return cleaned;
  }
}
