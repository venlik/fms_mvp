// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/invoice_details_comparison.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

/// Editable content for a not-yet-issued invoice.
/// No documentNumber, no derived totals stored.
class DraftInvoice with InvoiceDetailsComparison {
  @override
  Business? business;
  @override
  Customer? customer;
  @override
  DateTime date;
  @override
  PaymentTerms terms;
  @override
  List<InvoiceItem> items;
  String? notes;

  static const _notSet = Object();

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
    } else {
      throw AlreadyExists("Item already Exists");
    }
  }

  void removeItem(InvoiceItem item) {
    if (items.contains(item)) {
      items.remove(item);
    } else {
      throw NotFound("Item not found");
    }
  }

  void replaceItem(InvoiceItem oldItem, InvoiceItem newItem) {
    final index = items.indexOf(oldItem);
    if (index == -1) {
      throw NotFound('originalItem not found');
    }
    final existing = items[index];

    if (items.contains(newItem) && existing.quantity == newItem.quantity) {
      throw AlreadyExists('replacement Item already exists');
    }
    items[index] = newItem;
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
      terms: terms,
      notes: notes,
    );
  }

  DraftInvoice copyWith({
    Object? business = _notSet,
    Object? customer = _notSet,
    DateTime? date,
    PaymentTerms? terms,
    Set<InvoiceItem>? items,
    Object? notes = _notSet,
  }) {
    return DraftInvoice(
      business: identical(business, _notSet)
          ? this.business
          : business as Business?,
      customer: identical(customer, _notSet)
          ? this.customer
          : customer as Customer?,
      date: date ?? this.date,
      terms: terms ?? this.terms,
      items: items ?? this.items.toSet(),
      notes: identical(notes, _notSet) ? this.notes : notes as String?,
    );
  }
}
