// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/invoice_details_comparison.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

class Invoice with InvoiceDetailsComparison {
  final DocumentNumber<Invoice> documentNumber;
  @override
  final DateTime date;
  @override
  final Business business;
  @override
  final Customer customer;
  @override
  final Set<InvoiceItem> items;

  @override
  final PaymentTerms terms;
  final String? notes;
  final bool isDeleted;

  static const _notSet = Object();

  Invoice({
    required this.documentNumber,
    required this.date,
    required this.business,
    required this.customer,
    required Set<InvoiceItem> items,
    required this.terms,
    this.notes,
    this.isDeleted = false,
  }) : items = Set.unmodifiable(items);

  DateTime get dueDate => terms.dueDate(date);
  
  int get totalCents =>
      items.fold(0, (sum, it) => sum + it.priceInCents * it.quantity);

  Invoice copyWith({
    DocumentNumber<Invoice>? documentNumber,
    DateTime? date,
    Business? business,
    Customer? customer,
    Set<InvoiceItem>? items,
    PaymentTerms? terms,
    Object? notes = _notSet,
    bool? isDeleted,
  }) {
    return Invoice(
      documentNumber: documentNumber ?? this.documentNumber,
      date: date ?? this.date,
      business: business ?? this.business,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      terms: terms ?? this.terms,
      notes: identical(notes, _notSet) ? this.notes : notes as String?,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
