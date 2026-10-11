import 'package:finance_management_system/backend/details/invoice_details.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';

mixin InvoiceDetailsComparison {
  Business? get business;
  Customer? get customer;
  Iterable<InvoiceItem> get items;
  PaymentTerms get terms;
  DateTime get date;

  InvoiceDetails get details {
    final b = business;
    final c = customer;
    if (b == null || c == null) {
      throw StateError('Cannot compute details: business/customer missing');
    }
    return InvoiceDetails(
      businessId: b.id,
      customerId: c.id,
      items: items.toSet(),
      terms: terms,
      date: date,
    );
  }
}