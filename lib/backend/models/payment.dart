// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/payment_details_comparison.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';

class Payment with PaymentDetailsComparison implements Entity {
  final Identifier<Payment> id;
  @override
  final int amountInCents;
  @override
  final PaymentMethod method;
  @override
  final DocumentNumber<Invoice> invoiceNumber;
  @override
  final DateTime date;
  @override
  final String? reference;
  final String? notes;
  final bool isDeleted;

  Payment({
    required this.id,
    required int amountInCents,
    required this.method,
    required this.invoiceNumber,
    required this.date,
    this.reference,
    this.notes,
    this.isDeleted = false,
  }) : amountInCents = amountInCents > 0
           ? amountInCents
           : throw StateError(
               "Amount must be greater than 0: amountInCents=$amountInCents",
             );

  static const _notSet = Object();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Payment && other.id == id);

  @override
  int get hashCode => id.hashCode;

  Payment copyWith({
    Identifier<Payment>? id,
    int? amountInCents,
    PaymentMethod? method,
    DocumentNumber<Invoice>? invoiceNumber,
    DateTime? date,
    Object? reference = _notSet,
    Object? notes = _notSet,
    bool? isDeleted,
  }) {
    return Payment(
      id: id ?? this.id,
      amountInCents: amountInCents ?? this.amountInCents,
      method: method ?? this.method,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      reference: identical(reference, _notSet)
          ? this.reference
          : reference as String?,
      notes: identical(notes, _notSet) ? this.notes : notes as String?,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
