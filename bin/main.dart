import 'package:finance_management_system/backend/drafts/draft_business.dart';
import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/drafts/draft_payment.dart';
import 'package:finance_management_system/backend/enums/entity_type.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/logo.dart';
import 'package:finance_management_system/backend/services/bootstrap.dart';
import 'package:finance_management_system/frontend/cli/cli_services/cli_logo_store.dart';
import 'package:finance_management_system/frontend/cli/cli_services/cli_storage.dart';

void main() async {
  const env = {
    'APP_DIR': 'z_store/.app',
    'DOCS_DIR': 'z_store/.docs',
    'DOWNLOAD_DIR': 'z_store/.downloads',
  };
  final storage = CLIStorage.fromEnvironment(env);
  final store = LocalLogoStore();

  final services = await bootStrapServices(storage, store);
  final repo = services.repos;
  final itemService = services.itemService;

  final invoiceService = services.invoiceService;
  final receiptService = services.receiptService;
  final item = DraftItem(
    name: "Flutter item",
    description: 'an items that dances on a GUI',
    priceInCents: 200,
  );
  try {
    await itemService.commit(item);
  } catch (e) {
    _print_E_(e);
  }

  try {
    await repo.businesses.commit(
      DraftBusiness(
        name: "KONSOLE",
        logo: Logo(path: 'assets/logo.jpg', source: Source.file),
        phoneNumber: '000-222-333-546',
        email: "konsole@fedora.plasma",
        serviceLocation: 'hp elitebook 840 g5',
        configuredCurrency: 'KES',
      ),
    );
  } catch (e) {
    _print_E_(e);
  }

  try {
    await repo.customers.commit(
      DraftCustomer(
        name: "Kevo",
        address: "Karatina",
        phoneNumber: "222-666-233-456",
      ),
    );
  } catch (e) {
    _print_E_(e);
  }

  try {
    await invoiceService.commit(
      DraftInvoice(
        business: await repo.businesses.findById(
          Identifier(1, EntityType.business),
        ),
        customer: await repo.customers.findById(
          Identifier(1, EntityType.customer),
        ),
        date: DateTime.now(),
        terms: PaymentTerms.net7,
        items: {
          InvoiceItem(item: (await itemService.findAll()).last, quantity: 4),
        },
      ),
    );
  } catch (e) {
    _print_E_(e);
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
        ),
      );
      final receipt = await receiptService.generate(invoice: inv, payment: pay);
      print('saving invoice....');
      await invoiceService.saveAsPdf(inv.documentNumber);
      print('saving receipt...');
      await receiptService.saveAsPdf(receipt);
    } catch (e) {
      _print_E_(e);
    }
  }
  print("done");
}

void _print_E_(dynamic e) {
  print(e);
}
