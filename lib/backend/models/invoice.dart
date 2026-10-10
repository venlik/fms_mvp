// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

class Invoice {
  final DocumentNumber<Invoice> documentNumber;
  final DateTime date;
  final Business business;
  final Customer customer;
  final Set<InvoiceItem> items;
  final PaymentTerms paymentTerms;
  final String? notes;

  Invoice({
    required this.documentNumber,
    required this.date,
    required this.business,
    required this.customer,
    required Set<InvoiceItem> items,
    required this.paymentTerms,
    this.notes,
  }) : items = Set.unmodifiable(items);

  DateTime get dueDate => paymentTerms.dueDate(date);

  Map<String, dynamic> toMap() {
    return {
      'documentNumber': documentNumber.id,
      'date': date.toIso8601String(),
      'businessId': business.id.number,
      'customerId': customer.id.number,
      'items': items
          .map((it) => {'itemId': it.item.id.number, 'quantity': it.quantity})
          .toList(),
      'paymentTerms': paymentTerms.label,
      'notes': notes,
    };
  }

  int get _itemsHash =>
    items.fold(0, (h, item) => h ^ item.hashCode);

  int get contentHash =>
      business.contentHash ^
      customer.contentHash ^
      _itemsHash ^
      paymentTerms.hashCode << 10;
}
