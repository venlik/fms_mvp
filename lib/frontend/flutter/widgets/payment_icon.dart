import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/models/payment.dart';

/// Icon for a payment method. Used in the payments list, the payment
/// detail header, and the invoice detail's payments section.
class PaymentIcon extends StatelessWidget {
  final Payment payment;
  final double size;
  final Color? color;

  const PaymentIcon({
    super.key,
    required this.payment,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconForMethod(payment.method),
      size: size,
      color: color,
    );
  }
}

/// Bare resolver for callers that only have a [PaymentMethod] and
/// don't want to build a widget (e.g. inside a `ListTile.leading`).
IconData iconForMethod(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return Icons.payments_outlined;
    case PaymentMethod.mpesa:
      return Icons.phone_android_outlined;
    case PaymentMethod.card:
      return Icons.credit_card_outlined;
    case PaymentMethod.bankTransfer:
      return Icons.account_balance_outlined;
    case PaymentMethod.cheque:
      return Icons.receipt_outlined;
    case PaymentMethod.other:
      return Icons.more_horiz;
  }
}