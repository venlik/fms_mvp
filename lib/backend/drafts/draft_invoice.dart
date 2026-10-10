// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

/// Editable content for a not-yet-issued invoice.
/// No documentNumber, no derived totals stored.
class DraftInvoice {
  Business? business;
  Customer? customer;
  DateTime date;
  PaymentTerms terms;
  List<InvoiceItem> items;
  String? notes;

  DraftInvoice({
    this.business,
    this.customer,
    DateTime? date,
    this.terms = PaymentTerms.dueOnReceipt,
    Set<InvoiceItem>? items,
    this.notes,
  }) : date = date ?? DateTime.now(),
       items = items?.toSet().toList() ?? [];

  // ── Derived (computed, never stored) ───────────────────────────

  DateTime get dueDate => terms.dueDate(date);

  int get subtotalCents => items.fold(0, (sum, i) => sum + i.lineTotalCents);

  bool get canIssue =>
      business != null &&
      customer != null &&
      items.isNotEmpty &&
      items.every((i) => i.quantity >= 1);

  // ── Item operations ────────────────────────────────────────────

  void addItem(InvoiceItem item) {
    if (!items.contains(item)) {
      items.add(item);
    }
  }

  void removeItem(InvoiceItem item) {
    if (items.contains(item)) {
      items.remove(item);
    }
  }

  void replaceItem(InvoiceItem oldItem, InvoiceItem newItem) {
    if (items.contains(oldItem) && !items.contains(newItem)) {
      //TODO: make this api return success/error status
      final index = items.indexOf(oldItem);
      if (index < 0) return;
      items[index] = newItem;
    }
  }

  // ── Commit ─────────────────────────────────────────────────────

  /// Builds the immutable [Invoice]. The caller supplies the
  /// [DocumentNumber] allocated by the service. Item IDs are assigned
  /// sequentially here — the UI never sees them.
  Invoice toInvoice(DocumentNumber<Invoice> number) {
    if (!canIssue) {
      throw StateError('Draft is not complete');
    }

    return Invoice(
      documentNumber: number,
      date: date,
      business: business!,
      customer: customer!,
      items: Set.of(items),
      paymentTerms: terms,
      notes: notes,
    );
  }

  DraftInvoice copyWith({
    Business? business,
    Customer? customer,
    DateTime? date,
    PaymentTerms? terms,
    Set<InvoiceItem>? items,
    String? notes,
  }) {
    return DraftInvoice(
      business: business ?? this.business,
      customer: customer ?? this.customer,
      date: date ?? this.date,
      terms: terms ?? this.terms,
      items: items ?? this.items.toSet(),
      notes: notes ?? this.notes,
    );
  }

  int get _itemsHash => items.fold(0, (h, item) => h ^ item.hashCode);

  int? get contentHash => canIssue
      ? business!.contentHash ^
            customer!.contentHash ^
            _itemsHash ^
            terms.hashCode << 10
      : null;
}
