import 'dart:typed_data';

import 'package:finance_management_system/backend/services/document_previewer.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/screens/pdf_preview_screen.dart';
import 'package:flutter/material.dart';

/// Shows PDF bytes in-app using `printing`'s `PdfPreview` widget.
///
/// The interface has no `BuildContext`, so this adapter pushes the
/// preview route through the app-wide [navigatorKey].
class FlutterPreviewer implements DocumentPreviewer {
  const FlutterPreviewer();

  @override
  Future<void> preview({
    required List<int> bytes,
    required String title,
  }) async {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      throw StateError(
        'FlutterPreviewer.preview called before Navigator is ready',
      );
    }
    await nav.push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          bytes: Uint8List.fromList(bytes),
          title: title,
        ),
      ),
    );
  }
}