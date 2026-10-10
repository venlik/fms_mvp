import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/pdf/document_fonts.dart';
import 'package:finance_management_system/backend/pdf/invoice_pdf.dart';
import 'package:finance_management_system/backend/repositories/invoice_repository.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

class InvoiceService {
  final InvoiceRepository _invoiceRepository;
  final Storage _storage;
  final LogoStore _store;

  InvoiceService._(this._invoiceRepository, this._storage, this._store);

  factory InvoiceService.of(InvoiceRepository ir, Storage st, LogoStore ls) =>
      InvoiceService._(ir, st, ls);

  DraftInvoice createDraftInvoice({
    required Business business,
    required Customer customer,
    required Set<InvoiceItem> items,
    required PaymentTerms paymentTerms,
    String? notes,
  }) => _invoiceRepository.createDraftInvoice(
    business: business,
    customer: customer,
    items: items,
    paymentTerms: paymentTerms,
    notes: notes,
  );

  Future<void> commit(DraftInvoice draft) async =>
      await _invoiceRepository.commit(draft);

  Future<Invoice?> findByNumber(int number) async =>
      await _invoiceRepository.findByNumber(number);

  Future<Iterable<Invoice>?> findAll() async =>
      await _invoiceRepository.findAll();

  Future<void> saveAsPdf(
    DocumentNumber<Invoice> ref, [
    String? name,
    DocumentFonts? fonts,
  ]) async {
    final invoice = await _invoiceRepository.findByNumber(ref.id);
    if (invoice == null) {
      throw Exception("Invoice(${ref.toString()}) not found");
    }
    final ipdf = InvoicePdf();
    //final pdf = await ipdf.generate(invoice, _store,fonts: fonts);
    final pdf = await ipdf.generate(
      invoice: invoice,
      store: _store,
      docNumber: invoice.documentNumber.toString(),
      fonts: fonts,
    );
    final pdfBytes = await ipdf.bytes(pdf);
    final resolvedName = name ?? "INV_${invoice.documentNumber.id}.pdf";
    await _storage.saveDocument(name: resolvedName, bytes: pdfBytes);
  }

  void preview(Invoice invoice) {}

  void print(Invoice invoice) {}
}
