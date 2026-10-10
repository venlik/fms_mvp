import 'package:finance_management_system/backend/models/invoice.dart';

/// Static formatting helpers shared by all document renderers.
class DocFormat {
  const DocFormat._();

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// "May 20, 2026"
  static String date(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// 12345.6 -> "12,345.60"
  static String money(double v) {
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

  /// 5 -> "5", 5.5 -> "5.5"
  static String number(num n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

  /// Sum of all line totals, in currency units (not cents).
  static double total(Invoice invoice) {
    final cents = invoice.items.fold<int>(
      0,
      (sum, it) => sum + it.priceInCents * it.quantity,
    );
    return cents / 100;
  }
}
