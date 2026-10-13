import 'package:finance_management_system/backend/details/payment_details.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

mixin PaymentDetailsComparison {
  int get amountInCents;
  PaymentMethod get method;
  DocumentNumber<Invoice> get invoiceNumber;
  String? get reference;
  DateTime get date;

  PaymentDetails get details => PaymentDetails(
    amountInCents: amountInCents,
    method: method,
    invoiceNumber: invoiceNumber,
    reference: reference,
    date: date
  );
}
