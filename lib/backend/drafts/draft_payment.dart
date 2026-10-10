// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

/// Editable content for a not-yet-recorded payment.
/// The invoice it settles is fixed at construction — the user can't
/// redirect a payment to a different invoice mid-form.
class DraftPayment {
  final DocumentNumber<Invoice> invoiceNumber;

  PaymentMethod method;
  int amountInCents;
  String reference;
  
  String? notes;

  DraftPayment({
    required this.invoiceNumber,
    this.method = PaymentMethod.cash,
    this.amountInCents = 0,

    required this.reference,
    this.notes,
  });

  bool get isValid => amountInCents > 0;

  DraftPayment copyWith({
    DocumentNumber<Invoice>? invoiceNumber,
    PaymentMethod? method,
    int? amountInCents,
    DateTime? date,
    String? reference,
    String? notes,
  }) {
    return DraftPayment(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      method: method ?? this.method,
      amountInCents: amountInCents ?? this.amountInCents,
      reference: reference ?? this.reference,

      notes: notes ?? this.notes,
    );
  }

  int get contentHash =>
      amountInCents.hashCode ^
      method.hashCode ^
      invoiceNumber.hashCode ^
      reference.hashCode << 10;
}
