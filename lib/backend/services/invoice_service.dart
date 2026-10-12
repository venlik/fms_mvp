import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/pdf/document_fonts.dart';
import 'package:finance_management_system/backend/pdf/invoice_pdf.dart';
import 'package:finance_management_system/backend/repositories/invoice_repository.dart';
import 'package:finance_management_system/backend/repositories/payment_repository.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

class InvoiceService {
  final InvoiceRepository _invoices;
  final PaymentRepository _payments; // ← added
  final Storage _storage;
  final LogoStore _store;

  InvoiceService._(
    this._invoices,
    this._payments,
    this._storage,
    this._store,
  );

  factory InvoiceService.of(
    InvoiceRepository ir,
    PaymentRepository pr,
    Storage st,
    LogoStore ls,
  ) => InvoiceService._(ir, pr, st, ls);

  DraftInvoice createDraftInvoice({
    required Business business,
    required Customer customer,
    required Set<InvoiceItem> items,
    required PaymentTerms paymentTerms,
    String? notes,
  }) => _invoices.createDraftInvoice(
    business: business,
    customer: customer,
    items: items,
    paymentTerms: paymentTerms,
    notes: notes,
  );

  Future<Invoice> commit(DraftInvoice draft) async =>
      await _invoices.commit(draft);

  Future<Invoice?> findByNumber(DocumentNumber<Invoice> number) async =>
      await _invoices.findByNumber(number);

  Future<Iterable<Invoice>?> findAll() async => await _invoices.findAll();

  Future<void> saveAsPdf(
    DocumentNumber<Invoice> ref, [
    String? name,
    DocumentFonts? fonts,
  ]) async {
    final invoice = await _invoices.findByNumber(ref);
    if (invoice == null) {
      throw NotFound('Invoice ${ref.toString()} not found');
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

  /// Balance due on [number]: invoice total minus payments received.
  /// Positive = still owed. Zero = paid. Negative = overpaid.
  /// Throws [NotFound] if the invoice doesn't exist.
  Future<int> balanceCents(DocumentNumber<Invoice> number) async {
    final invoice = await _invoices.findByNumber(number);
    if (invoice == null) {
      throw NotFound('Invoice $number not found');
    }
    final payments = await _payments.findByInvoice(number);
    final paid = payments.fold<int>(0, (sum, p) => sum + p.amountInCents);
    return invoice.totalCents - paid;
  }

  void preview(Invoice invoice) {}

  void print(Invoice invoice) {}
}
