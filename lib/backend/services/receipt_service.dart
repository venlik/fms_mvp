import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/models/receipt.dart';
import 'package:finance_management_system/backend/pdf/document_fonts.dart';
import 'package:finance_management_system/backend/pdf/receipt_pdf.dart';
import 'package:finance_management_system/backend/repositories/receipt_repository.dart';
import 'package:finance_management_system/backend/services/document_previewer.dart';
import 'package:finance_management_system/backend/services/document_printer.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

class ReceiptService {
  final ReceiptRepository _receipts;
  final Storage _storage;
  final LogoStore _store;

  ReceiptService._(this._receipts, this._storage, this._store);

  factory ReceiptService.of(
    ReceiptRepository receipts,
    Storage storage,
    LogoStore store,
  ) => ReceiptService._(receipts, storage, store);

  // ── Lookup / creation ───────────────────────────────────────────

  /// Gets the receipt for [payment], creating one on first request.
  ///
  /// Idempotent: repeated calls for the same payment return the same
  /// receipt without allocating a new number. This is the fix for
  /// the number-burn that used to happen on every preview/print.
  Future<Receipt> forPayment({
    required Invoice invoice,
    required Payment payment,
  }) => _receipts.forPayment(invoice: invoice, payment: payment);

  // ── Rendering / dispatch ────────────────────────────────────────

  Future<void> saveAsPdf(
    Receipt receipt, {
    String? name,
    DocumentFonts? fonts,
  }) async {
    final resolvedName = name ?? _defaultFilename(receipt);
    final bytes = await _renderReceipt(receipt, fonts: fonts);
    await _storage.saveDocument(name: resolvedName, bytes: bytes);
  }

  Future<void> preview(
    Receipt receipt,
    DocumentPreviewer previewer, {
    DocumentFonts? fonts,
  }) async {
    final bytes = await _renderReceipt(receipt, fonts: fonts);
    await previewer.preview(bytes: bytes, title: _fileStem(receipt));
  }

  Future<void> print(
    Receipt receipt,
    DocumentPrinter printer, {
    DocumentFonts? fonts,
  }) async {
    final bytes = await _renderReceipt(receipt, fonts: fonts);
    await printer.print(bytes: bytes, jobName: _fileStem(receipt));
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _fileStem(Receipt r) =>
      'REC_${r.receiptId.id.toString().padLeft(4, '0')}';

  String _defaultFilename(Receipt r) => '${_fileStem(r)}.pdf';

  Future<List<int>> _renderReceipt(
    Receipt receipt, {
    DocumentFonts? fonts,
  }) async {
    final rpdf = ReceiptPdf(receipt);
    final doc = await rpdf.generate(
      invoice: receipt.invoice,
      store: _store,
      docNumber: receipt.receiptId.toString(),
      fonts: fonts,
    );
    return rpdf.bytes(doc);
  }
}