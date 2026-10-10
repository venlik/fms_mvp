enum PaymentMethod {
  cash(label: 'Cash'),
  mpesa(label: 'M-Pesa'),
  card(label: 'Card'),
  bankTransfer(label: 'Bank Transfer'),
  cheque(label: 'Cheque'),
  other(label: 'Other');

  const PaymentMethod({required this.label});

  final String label;
}
