import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/payment.dart';

abstract interface class PaymentLookup {
  Future<Payment?> findById(Identifier<Payment> id);
  Future<Iterable<Payment>> findByInvoice(int invoiceNumber);
}
