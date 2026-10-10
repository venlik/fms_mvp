enum PaymentTerms {
  dueOnReceipt(
    label: 'Due on receipt',
    days: 0,
  ),
  net7(
    label: 'Net 7',
    days: 7,
  ),
  net15(
    label: 'Net 15',
    days: 15,
  ),
  net30(
    label: 'Net 30',
    days: 30,
  ),
  net60(
    label: 'Net 60',
    days: 60,
  ),
  net90(
    label: 'Net 90',
    days: 90,
  );

  const PaymentTerms({required this.label, required this.days});

  /// Human-readable label shown on the invoice.
  final String label;

  /// Days from issue date to due date.
  final int days;

  /// Derived due date.
  DateTime dueDate(DateTime issued) =>
      DateTime(issued.year, issued.month, issued.day + days);

  /// Convenience for parsing "Net 30", "Due on receipt", etc.
  static PaymentTerms? fromLabel(String label) {
    for (final t in PaymentTerms.values) {
      if (t.label.toLowerCase() == label.toLowerCase()) return t;
    }
    return null;
  }
}