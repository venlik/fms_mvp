import 'package:flutter/material.dart';

/// Formats an integer cents value as a currency string.
///
/// This deliberately duplicates the formatting rule from
/// `backend/pdf/document_formatting.dart` rather than importing it:
/// the PDF module pulls in the `pdf` package, which we don't want in
/// the widget tree.
class MoneyText extends StatelessWidget {
  final int cents;
  final String currency;
  final TextStyle? style;
  final bool showSign;

  const MoneyText({
    super.key,
    required this.cents,
    required this.currency,
    this.style,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final negative = cents < 0;
    final display = negative ? -cents : cents;
    final sign = showSign
        ? (negative ? '-' : '+')
        : (negative ? '-' : '');
    return Text(
      '$sign$currency ${formatMoney(display)}',
      style: style,
    );
  }
}

/// Bare formatter for cases where a `Text` widget won't do (e.g.
/// composing a longer string).
String formatMoney(int cents) {
  final v = cents / 100;
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${buf.toString()}.${parts[1]}';
}