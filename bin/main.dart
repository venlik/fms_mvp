import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/drafts/draft_payment.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/services/bootstrap.dart';
import 'package:finance_management_system/frontend/cli/cli_services/cli_logo_store.dart';
import 'package:finance_management_system/frontend/cli/cli_services/cli_storage.dart';
import 'package:finance_management_system/test%20files/dummy_objects.dart';

void main() async {
  const env = {
    'APP_DIR': 'z_store.dbg/.app',
    'DOCS_DIR': 'z_store.dbg/.docs',
    'DOWNLOAD_DIR': 'z_store.dbg/.downloads',
  };
  final storage = CLIStorage.fromEnvironment(env);
  final store = LocalLogoStore();

  final services = await bootStrapServices(storage, store);
  final repo = services.repos;
  final itemService = services.itemService;

  final invoiceService = services.invoiceService;
  final receiptService = services.receiptService;

  try {
    await itemService.commitAll(popularClothingItems);
  } catch (e) {
    _print(e);
  }

  try {
    await repo.businesses.commit(dummyBusiness);
  } catch (e) {
    _print(e);
  }

  try {
    await repo.businesses.commit(dummyBusiness1);
  } catch (e) {
    _print(e);
  }

  try {
    await repo.customers.commit(dummyCustomer);
  } catch (e) {
    _print(e);
  }

  try {
    await repo.customers.commit(dummyCustomer1);
  } catch (e) {
    _print(e);
  }

  try {
    await invoiceService.commit(
      DraftInvoice(
        business: await repo.businesses.findSingleton(),
        customer: (await repo.customers.findAll()).last,
        date: DateTime.now(),
        terms: PaymentTerms.net7,
        items: (await itemService.findAll()).map((item) {
          return InvoiceItem(item: item, quantity: item.id.number % 13 + 1);
        }).toSet(),
      ),
    );
  } catch (e) {
    _print(e);
  }

  final invEnt = await invoiceService.findAll();
  final inv = invEnt?.last;

  if (inv != null) {
    try {
      final pay = await repo.payments.commit(
        DraftPayment(
          invoiceNumber: inv.documentNumber,
          method: PaymentMethod.mpesa,
          amountInCents: 200,
          reference: "SQJT8U20JK",
          date: DateTime.timestamp(),
        ),
        await invoiceService.balanceCents(inv.documentNumber),
      );
      final receipt = await receiptService.generate(invoice: inv, payment: pay);
      _print('saving invoice....');
      await invoiceService.saveAsPdf(inv.documentNumber);
      _print('saving receipt...');

      await receiptService.saveAsPdf(receipt);
    } catch (e) {
      _print(e);
    }
  }
  _print("done");
}

void _print(dynamic e) {
  assert(() {
    // ignore: avoid_print
    print(e);
    return true;
  }());
}
