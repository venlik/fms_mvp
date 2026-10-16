import 'dart:io';

import 'package:open_filex/open_filex.dart';

/// Opens a file with the platform's default handler.
///
/// Implementations are chosen at construction time by [DocumentOpener.forPlatform]
/// so the rest of the app never sees a platform check.
abstract interface class DocumentOpener {
  /// Opens [path] with the system's default application.
  /// Throws if the platform reports the open failed.
  Future<void> open(String path);

  /// Picks the right implementation for the current platform.
  factory DocumentOpener.forPlatform() {
    if (Platform.isLinux) return const XdgDocumentOpener();
    return const OpenFilexDocumentOpener();
  }
}

// Linux — xdg-open, no plugin required
class XdgDocumentOpener implements DocumentOpener {
  const XdgDocumentOpener();

  @override
  Future<void> open(String path) async {
    final result = await Process.run('xdg-open', [path]);
    if (result.exitCode != 0) {
      throw Exception(
        'xdg-open failed (exit ${result.exitCode}): ${result.stderr}',
      );
    }
  }
}

// Windows / Android / iOS / macOS — open_filex
class OpenFilexDocumentOpener implements DocumentOpener {
  const OpenFilexDocumentOpener();

  @override
  Future<void> open(String path) async {
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      throw Exception(
        'Could not open file: ${result.message} (${result.type})',
      );
    }
  }
}
