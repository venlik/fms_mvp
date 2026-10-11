import 'package:finance_management_system/backend/repositories/bootstrap.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/services/invoice_service.dart';
import 'package:finance_management_system/backend/services/item_service.dart';
import 'package:finance_management_system/backend/services/receipt_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

final class Services({
  required final CounterService counterService,
  required final InvoiceService invoiceService,
  required final ItemService itemService,
  required final ReceiptService receiptService,
  required final Repositories repos,
}) {}

Future<Services> bootStrapServices(Storage storage, LogoStore store) async {
  final repos = await bootstrapRepositories(storage);
  final cs = repos.counters;
  final ivs = InvoiceService.of(repos.invoices, storage, store);
  final its = ItemService.of(repos.items);
  final rs = ReceiptService.of(cs, storage, store);
  return Services(
    counterService: cs,
    invoiceService: ivs,
    itemService: its,
    receiptService: rs,
    repos: repos,
  );
}
