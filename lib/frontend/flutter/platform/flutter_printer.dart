import 'dart:typed_data';

import 'package:finance_management_system/backend/services/document_printer.dart';
import 'package:printing/printing.dart';

/// Sends PDF bytes to the platform's print dialog via `printing`.
///
/// On desktop this opens the OS print panel; on Android it dispatches
/// to the Android print service. Both paths are handled by the
/// package — no platform branching here.
class FlutterPrinter implements DocumentPrinter {
  const FlutterPrinter();

  @override
  Future<void> print({
    required List<int> bytes,
    required String jobName,
  }) async {
    await Printing.layoutPdf(
      name: jobName,
      onLayout: (_) async => Uint8List.fromList(bytes),
    );
  }
}