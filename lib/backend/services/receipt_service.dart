import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/models/receipt.dart';
import 'package:finance_management_system/backend/pdf/document_fonts.dart';
import 'package:finance_management_system/backend/pdf/receipt_pdf.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

class ReceiptService {
  final CounterService _counterService;
  final Storage _storage;
  final LogoStore _store;

  ReceiptService._(this._counterService, this._storage, this._store);

  factory ReceiptService.of(CounterService cs, Storage st, LogoStore ls) =>
      ReceiptService._(cs, st, ls);

  /// Pairs a committed [payment] with its [invoice] into a [Receipt].
  /// Allocates a receipt number for the PDF header. Receipts are not
  /// persisted — the rendered PDF is the artifact of record.
  Future<Receipt> generate({
    required Invoice invoice,
    required Payment payment,
  }) async {
    if (invoice.documentNumber.id != payment.invoiceNumber.id) {
      throw StateError(
        'Payment references invoice ${payment.invoiceNumber}, '
        'but was paired with invoice ${invoice.documentNumber}',
      );
    }
    final n = await _counterService.allocate(CounterKey.receipt);
    return Receipt(
      receiptId: DocumentNumber<Receipt>(n),
      invoice: invoice,
      payment: payment,
    );
  }

  /// Renders the receipt and saves the PDF under [name]. If [name] is
  /// null, defaults to `REC_<id>.pdf`.
  Future<void> saveAsPdf(
    Receipt receipt, {
    String? name,
    DocumentFonts? fonts,
  }) async {
    final resolvedName = name ?? 'REC_${receipt.receiptId.id}.pdf';
    final rpdf = ReceiptPdf(receipt);
    final pdf = await rpdf.generate(
      invoice: receipt.invoice,
      store: _store,
      docNumber: receipt.receiptId.toString(),
      fonts: fonts,
    );
    final pdfBytes = await rpdf.bytes(pdf);
    await _storage.saveDocument(name: resolvedName, bytes: pdfBytes);
  }
}
