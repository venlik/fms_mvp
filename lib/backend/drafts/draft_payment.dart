// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/payment_details_comparison.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

/// Editable content for a not-yet-recorded payment.
/// The invoice it settles is fixed at construction — the user can't
/// redirect a payment to a different invoice mid-form.
class DraftPayment with PaymentDetailsComparison {
  @override
  final DocumentNumber<Invoice> invoiceNumber;
  @override
  final DateTime date;

  @override
  PaymentMethod method;
  @override
  int amountInCents;
  @override
  String? reference;

  String? notes;

  static const _notSet = Object();

  DraftPayment({
    required this.invoiceNumber,
    this.method = PaymentMethod.cash,
    int amountInCents = 0,
    this.reference,
    this.notes,
    required this.date,
  }) : amountInCents = amountInCents >= 0
           ? amountInCents
           : throw StateError("amount must be >= 0");

  bool get isValid => amountInCents > 0;

  DraftPayment copyWith({
    DocumentNumber<Invoice>? invoiceNumber,
    PaymentMethod? method,
    int? amountInCents,
    Object? reference = _notSet,
    Object? notes = _notSet,
    DateTime? date,
  }) {
    return DraftPayment(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      method: method ?? this.method,
      amountInCents: amountInCents ?? this.amountInCents,
      reference: identical(reference, _notSet)
          ? this.reference
          : reference as String?,
      notes: identical(notes, _notSet) ? this.notes : notes as String?,
      date: date ?? this.date,
    );
  }
}
