import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// In-app PDF preview. View-only toolbar (no print, no share) — the
/// app bar carries the share action so the toolbar stays focused on
/// navigation and zoom.
class PdfPreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String title;

  const PdfPreviewScreen({super.key, required this.bytes, required this.title});

  Future<void> _share(BuildContext context) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: '$title.pdf');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text('Could not share: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => bytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
        pdfFileName: title,
      ),
    );
  }
}
