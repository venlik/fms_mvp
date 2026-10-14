// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/invoice_details_comparison.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/item.dart';

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

  List<InvoiceItem> _items;
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
       _items = items?.toSet().toList() ?? [];
       
  @override
  List<InvoiceItem> get items => List.unmodifiable(_items);

  List<InvoiceItem> get _snapshot => List.of(_items);
  // ── Derived (computed, never stored) ───────────────────────────

  DateTime get dueDate => terms.dueDate(date);

  int get subtotalCents => _items.fold(0, (sum, i) => sum + i.lineTotalCents);

  bool get canIssue =>
      business != null &&
      customer != null &&
      _items.isNotEmpty &&
      _items.every((i) => i.quantity >= 1);

  // ── Item operations ────────────────────────────────────────────

  void addItem(InvoiceItem item, {List<InvoiceItem>? target}) {
    final itms = target ?? _items;
    if (!itms.contains(item)) {
      itms.add(item);
    } else {
      throw AlreadyExists("Item already Exists");
    }
  }

  void removeItem(InvoiceItem item, {List<InvoiceItem>? target}) {
    final itms = target ?? _items;
    if (itms.contains(item)) {
      itms.remove(item);
    } else {
      throw NotFound("Item not found");
    }
  }

  void replaceItem(
    InvoiceItem oldItem,
    InvoiceItem newItem, {
    List<InvoiceItem>? target,
  }) {
    final itms = target ?? _items;
    final index = itms.indexOf(oldItem);
    if (index == -1) {
      throw NotFound('originalItem not found');
    }
    final existing = itms[index];

    if (itms.contains(newItem) && existing.quantity == newItem.quantity) {
      throw AlreadyExists('replacement Item already exists');
    }
    itms[index] = newItem;
  }

  void modifyQuantity(
    Identifier<Item> itemId,
    int quantity, {
    List<InvoiceItem>? target,
  }) {
    final itms = target ?? _items;
    final index = itms.indexWhere((entry) => entry.item.id == itemId);

    if (index == -1) {
      throw NotFound('Invoice item not found');
    }

    final snapshot = _snapshot;
    final existing = snapshot.removeAt(index);

    // Validate and add to the snapshot, not the original items.
    addItem(
      InvoiceItem(item: existing.item, quantity: quantity),
      target: snapshot,
    );

    itms
      ..clear()
      ..addAll(snapshot);
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
      items: Set.of(_items),
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
      items: items ?? _items.toSet(),
      notes: identical(notes, _notSet) ? this.notes : notes as String?,
    );
  }
}
