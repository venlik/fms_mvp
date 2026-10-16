import 'package:finance_management_system/backend/details/equatable.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

/// The fields that determine when two invoices describe the same
/// transaction.
///
/// Included:
///   • businessId  — which business issued it
///   • customerId  — who it's for
///   • items       — what was sold (sorted, compared element-wise)
///   • terms       — payment terms
///   • date        — the issue date
///
/// Intentionally excluded:
///   • notes        — annotation, not content
///   • documentNumber — object identity; not part of "same invoice"
///   • total/derived — computed from items
class InvoiceDetails with Equatable {
  final Identifier<Business> businessId;
  final Identifier<Customer> customerId;
  final List<InvoiceItem> items; // sorted
  final PaymentTerms terms;
  final DateTime date;

  InvoiceDetails({
    required this.businessId,
    required this.customerId,
    required Set<InvoiceItem> items,
    required this.terms,
    required this.date,
  }) : items = _sorted(items);

  static List<InvoiceItem> _sorted(Set<InvoiceItem> items) {
    final list = items.toList()
      ..sort((a, b) => a.item.id.number.compareTo(b.item.id.number));
    return List.unmodifiable(list);
  }

  @override
  List<Object?> get props => [
    businessId,
    customerId,
    ...items.map((it) => (it.item, it.quantity)),
    terms,
    date,
  ];

  @override
  String toString() =>
      'InvoiceDetails(business: $businessId, customer: $customerId, '
      'items: ${items.length}, date: $date)';
}
