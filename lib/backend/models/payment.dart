import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

class Payment implements Entity {
  final Identifier<Payment> id;
  final int amountInCents;
  final PaymentMethod method;
  final DocumentNumber<Invoice> invoiceNumber;
  final DateTime date;
  final String reference;
  final String? notes;

  const Payment({
    required this.id,
    required this.amountInCents,
    required this.method,
    required this.invoiceNumber,
    required this.date,
    required this.reference,
    this.notes,
  });

 int get contentHash =>
      amountInCents.hashCode ^
      method.hashCode ^
      invoiceNumber.hashCode ^
      reference.hashCode << 10;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Payment && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
