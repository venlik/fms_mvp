import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';

abstract interface class PaymentLookup {
  Future<Payment?> findById(Identifier<Payment> id);
  Future<Iterable<Payment>> findByInvoice(
    DocumentNumber<Invoice> invoiceNumber, {
    bool includeDeleted = false,
  });
}
