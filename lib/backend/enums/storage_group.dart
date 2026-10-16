enum StorageGroup {
  config(file: 'config.json'),
  counters(file: 'counters.json'),
  items(file: 'items.json'),
  invoices(file: 'invoices.json'),
  payments(file: 'payments.json'),
  businesses(file: 'businesses.json'),
  customers(file: 'customers.json'),
  receipts(file: 'receipts.json');

  const StorageGroup({required this.file});
  final String file;
}

typedef SG = StorageGroup;
