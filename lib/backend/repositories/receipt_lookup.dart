import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/models/receipt.dart';

abstract interface class ReceiptLookup {
  Future<Receipt?> findById(Identifier<Receipt> id);

  Future<Receipt?> findByNumber(DocumentNumber<Receipt> number);

  Future<Receipt?> findByPayment(
    Identifier<Payment> paymentId, {
    bool includeDeleted = false,
  });
}