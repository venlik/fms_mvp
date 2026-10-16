// bootstrap.dart
import 'package:finance_management_system/backend/repositories/business_repository.dart';
import 'package:finance_management_system/backend/repositories/customer_repository.dart';
import 'package:finance_management_system/backend/repositories/invoice_repository.dart';
import 'package:finance_management_system/backend/repositories/item_repository.dart';
import 'package:finance_management_system/backend/repositories/payment_repository.dart';
import 'package:finance_management_system/backend/repositories/receipt_repository.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

class Repositories({
  required final CounterService counters,
  required final BusinessRepository businesses,
  required final CustomerRepository customers,
  required final ItemRepository items,
  required final InvoiceRepository invoices,
  required final PaymentRepository payments,
  required final ReceiptRepository receipts,
}) {}

Future<Repositories> bootstrapRepositories(Storage storage) async {
  final counters = CounterService(storage);

  final businesses = await BusinessRepository.create(
    storage: storage,
    counters: counters,
  );
  final customers = await CustomerRepository.create(
    storage: storage,
    counters: counters,
  );
  final items = await ItemRepository.create(
    storage: storage,
    counters: counters,
  );

  final invoices = await InvoiceRepository.create(
    storage: storage,
    counters: counters,
    customers: customers,
    businesses: businesses,
    items: items,
  );

  final payments = await PaymentRepository.create(
    storage: storage,
    counters: counters,
    invoices: invoices, // only needs InvoiceLookup
  );
  final receipts = await ReceiptRepository.create(
    storage: storage,
    counters: counters,
    invoices: invoices,
    payments: payments,
  );

  return Repositories(
    counters: counters,
    businesses: businesses,
    customers: customers,
    items: items,
    invoices: invoices,
    payments: payments,
    receipts: receipts,
  );
}
