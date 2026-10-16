import 'package:finance_management_system/backend/details/equatable.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

/// The fields that determine when two payments are the same
/// transaction.
///
/// Included:
///   • [amountInCents]  — how much
///   • [method]         — how it was paid
///   • [invoiceNumber]  — which invoice it settles
///   • [reference]      — external reference (M-Pesa code, cheque no.)
///   • [date]      — original timestamp of the payment recording(with upto microsecond accuracy)
/// Note: if [reference] is empty or generic (e.g. "cash"), two
/// otherwise-identical payments are indistinguishable. That's the
/// limit of the data model — the reference is the disambiguator.
class PaymentDetails with Equatable {
  final int amountInCents;
  final PaymentMethod method;
  final DocumentNumber<Invoice> invoiceNumber;
  final String? reference;
  final DateTime date;

  const PaymentDetails({
    required this.amountInCents,
    required this.method,
    required this.invoiceNumber,
    this.reference,
    required this.date,
  });

  @override
  List<Object?> get props => [
    amountInCents,
    method,
    invoiceNumber,
    reference,
    date,
  ];

  @override
  String toString() =>
      'PaymentDetails(amount: $amountInCents, method: ${method.name}, '
      'invoice: $invoiceNumber, ref: $reference)';
}
