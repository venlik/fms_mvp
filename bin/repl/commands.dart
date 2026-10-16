// bin/repl/commands.dart

import 'dart:io';

import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/drafts/draft_payment.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/backend/services/bootstrap.dart';

import 'tokenizer.dart';

typedef CommandHandler = Future<void> Function(List<String> args, Services s);

final Map<String, CommandHandler> commands = {
  'help': _help,
  'business': _business,
  'customer': _customer,
  'item': _item,
  'invoice': _invoice,
  'payment': _payment,
  'receipt': _receipt,
  'counter': _counter,
};

Future<void> dispatch(String line, Services services) async {
  final tokens = tokenize(line);
  if (tokens.isEmpty) return;

  final name = tokens.first.toLowerCase();
  final args = tokens.sublist(1);

  final handler = commands[name];
  if (handler == null) {
    stdout.writeln('unknown: $name — try "help"');
    return;
  }

  await handler(args, services);
}

// ─────────────────────────────────────────────────────────────────────
// help
// ─────────────────────────────────────────────────────────────────────

Future<void> _help(List<String> args, Services s) async {
  stdout
    ..writeln('business show')
    ..writeln('customer list | add <name> <phone> <address> [email] | show <id>')
    ..writeln('item list | add <name> <price-cents> <description> | show <id>')
    ..writeln('invoice list | create <customer-id> <item-id> [<item-id>...] '
        '[terms:<label>] | show <num> | pdf <num>')
    ..writeln('payment list | add <invoice-num> <amount-cents> '
        '[method:<label>] [ref:<text>] | show <id>')
    ..writeln('receipt list | for <payment-id> | pdf <receipt-num>')
    ..writeln('counter show')
    ..writeln('exit | quit');
}

// ─────────────────────────────────────────────────────────────────────
// helpers
// ─────────────────────────────────────────────────────────────────────

/// Pulls a named argument out of [args], in the form `key:value`.
/// Returns null if absent. Leaves [args] otherwise untouched.
String? _named(List<String> args, String key) {
  for (final a in args) {
    if (a.startsWith('$key:')) return a.substring(key.length + 1);
  }
  return null;
}

/// Removes any `key:value` tokens from [args], returning the rest.
List<String> _positional(List<String> args) {
  return args.where((a) => !a.contains(':')).toList();
}

Future<Customer?> _findCustomer(Services s, int id) async {
  final all = await s.repos.customers.findAll();
  for (final c in all) {
    if (c.id.number == id) return c;
  }
  return null;
}

Future<Item?> _findItem(Services s, int id) async {
  final all = await s.itemService.findAll();
  for (final it in all) {
    if (it.id.number == id) return it;
  }
  return null;
}

Future<Invoice?> _findInvoice(Services s, int num) async {
  try {
    return await s.repos.invoices.findByNumber(
      DocumentNumber<Invoice>(num),
      includeDeleted: true,
    );
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────
// business
// ─────────────────────────────────────────────────────────────────────

Future<void> _business(List<String> args, Services s) async {
  if (args.isEmpty || args.first != 'show') {
    stdout.writeln('usage: business show');
    return;
  }
  try {
    final b = await s.repos.businesses.findSingleton();
    stdout
      ..writeln('id       : ${b.id}')
      ..writeln('name     : ${b.name}')
      ..writeln('phone    : ${b.phoneNumber}')
      ..writeln('email    : ${b.email}')
      ..writeln('location : ${b.serviceLocation}')
      ..writeln('currency : ${b.configuredCurrency}');
  } catch (_) {
    stdout.writeln('no business configured');
  }
}

// ─────────────────────────────────────────────────────────────────────
// customer
// ─────────────────────────────────────────────────────────────────────

Future<void> _customer(List<String> args, Services s) async {
  if (args.isEmpty) {
    stdout.writeln('usage: customer <list|add|show> ...');
    return;
  }
  switch (args.first) {
    case 'list':
      final all = await s.repos.customers.findAll();
      if (all.isEmpty) {
        stdout.writeln('(no customers)');
        return;
      }
      for (final c in all) {
        stdout.writeln('${c.id}  ${c.name}  ${c.phoneNumber}');
      }

    case 'add':
      final pos = _positional(args.skip(1).toList());
      if (pos.length < 3) {
        stdout.writeln(
          'usage: customer add <name> <phone> <address> [email]',
        );
        return;
      }
      final draft = DraftCustomer(
        name: pos[0],
        phoneNumber: pos[1],
        address: pos[2],
        email: pos.length > 3 ? pos[3] : null,
      );
      final c = await s.repos.customers.commit(draft);
      stdout.writeln('created: ${c.id}  ${c.name}');

    case 'show':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: customer show <id>');
        return;
      }
      final id = int.tryParse(pos.first);
      if (id == null) {
        stdout.writeln('id must be a number');
        return;
      }
      final c = await _findCustomer(s, id);
      if (c == null) {
        stdout.writeln('not found');
        return;
      }
      stdout
        ..writeln('id       : ${c.id}')
        ..writeln('name     : ${c.name}')
        ..writeln('phone    : ${c.phoneNumber}')
        ..writeln('address  : ${c.address}')
        ..writeln('email    : ${c.email ?? "—"}');

    default:
      stdout.writeln('unknown: customer ${args.first}');
  }
}

// ─────────────────────────────────────────────────────────────────────
// item
// ─────────────────────────────────────────────────────────────────────

Future<void> _item(List<String> args, Services s) async {
  if (args.isEmpty) {
    stdout.writeln('usage: item <list|add|show> ...');
    return;
  }
  switch (args.first) {
    case 'list':
      final all = await s.itemService.findAll();
      if (all.isEmpty) {
        stdout.writeln('(no items)');
        return;
      }
      for (final it in all) {
        stdout.writeln('${it.id}  ${it.name}  ${it.priceInCents}c');
      }

    case 'add':
      final pos = _positional(args.skip(1).toList());
      if (pos.length < 3) {
        stdout.writeln('usage: item add <name> <price-cents> <description>');
        return;
      }
      final cents = int.tryParse(pos[1]);
      if (cents == null) {
        stdout.writeln('price must be an integer (cents)');
        return;
      }
      final draft = DraftItem(
        name: pos[0],
        priceInCents: cents,
        description: pos[2],
      );
      final it = await s.itemService.commit(draft);
      stdout.writeln('created: ${it.id}  ${it.name}');

    case 'show':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: item show <id>');
        return;
      }
      final id = int.tryParse(pos.first);
      if (id == null) {
        stdout.writeln('id must be a number');
        return;
      }
      final it = await _findItem(s, id);
      if (it == null) {
        stdout.writeln('not found');
        return;
      }
      stdout
        ..writeln('id          : ${it.id}')
        ..writeln('name        : ${it.name}')
        ..writeln('description : ${it.description}')
        ..writeln('price       : ${it.priceInCents}c');

    default:
      stdout.writeln('unknown: item ${args.first}');
  }
}

// ─────────────────────────────────────────────────────────────────────
// invoice
// ─────────────────────────────────────────────────────────────────────

Future<void> _invoice(List<String> args, Services s) async {
  if (args.isEmpty) {
    stdout.writeln('usage: invoice <list|create|show|pdf> ...');
    return;
  }
  switch (args.first) {
    case 'list':
      final all = await s.invoiceService.findAll();
      if (all == null || all.isEmpty) {
        stdout.writeln('(no invoices)');
        return;
      }
      for (final inv in all) {
        stdout.writeln(
          '${inv.documentNumber}  ${inv.customer.name}  '
          '${inv.totalCents}c  ${inv.date.toIso8601String().split("T").first}',
        );
      }

    case 'create':
      final pos = _positional(args.skip(1).toList());
      if (pos.length < 2) {
        stdout.writeln(
          'usage: invoice create <customer-id> <item-id> [<item-id>...] '
          '[terms:<label>]',
        );
        return;
      }

      final customerId = int.tryParse(pos[0]);
      if (customerId == null) {
        stdout.writeln('customer-id must be a number');
        return;
      }
      final customer = await _findCustomer(s, customerId);
      if (customer == null) {
        stdout.writeln('customer not found');
        return;
      }

      final items = <InvoiceItem>{};
      for (final raw in pos.skip(1)) {
        final id = int.tryParse(raw);
        if (id == null) {
          stdout.writeln('item-id must be a number: $raw');
          return;
        }
        final item = await _findItem(s, id);
        if (item == null) {
          stdout.writeln('item not found: $id');
          return;
        }
        items.add(InvoiceItem(item: item, quantity: 1));
      }
      if (items.isEmpty) {
        stdout.writeln('no items selected');
        return;
      }

      final termsLabel = _named(args, 'terms');
      final terms = termsLabel == null
          ? PaymentTerms.dueOnReceipt
          : PaymentTerms.fromLabel(termsLabel) ??
              (throw ArgumentError('unknown terms: $termsLabel'));

      final business = await s.repos.businesses.findSingleton();
      final draft = DraftInvoice(
        business: business,
        customer: customer,
        date: DateTime.now(),
        terms: terms,
        items: items,
      );

      final inv = await s.invoiceService.commit(draft);
      stdout.writeln('created: ${inv.documentNumber}  ${inv.totalCents}c');

    case 'show':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: invoice show <num>');
        return;
      }
      final num = int.tryParse(pos.first);
      if (num == null) {
        stdout.writeln('num must be a number');
        return;
      }
      final inv = await _findInvoice(s, num);
      if (inv == null) {
        stdout.writeln('not found');
        return;
      }
      final balance = await s.invoiceService.balanceCents(inv.documentNumber);
      stdout
        ..writeln('number   : ${inv.documentNumber}')
        ..writeln('customer : ${inv.customer.name}')
        ..writeln('date     : ${inv.date.toIso8601String().split("T").first}')
        ..writeln('terms    : ${inv.terms.label}')
        ..writeln('total    : ${inv.totalCents}c')
        ..writeln('balance  : ${balance}c');
      for (final it in inv.items) {
        stdout.writeln(
          '  ${it.quantity} × ${it.name} @ ${it.priceInCents}c '
          '= ${it.lineTotalCents}c',
        );
      }

    case 'pdf':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: invoice pdf <num>');
        return;
      }
      final num = int.tryParse(pos.first);
      if (num == null) {
        stdout.writeln('num must be a number');
        return;
      }
      await s.invoiceService.saveAsPdf(DocumentNumber<Invoice>(num));
      stdout.writeln('saved INV_${num.toString().padLeft(4, "0")}.pdf');

    default:
      stdout.writeln('unknown: invoice ${args.first}');
  }
}

// ─────────────────────────────────────────────────────────────────────
// payment
// ─────────────────────────────────────────────────────────────────────

Future<void> _payment(List<String> args, Services s) async {
  if (args.isEmpty) {
    stdout.writeln('usage: payment <list|add|show> ...');
    return;
  }
  switch (args.first) {
    case 'list':
      final all = await s.repos.payments.findAll();
      if (all.isEmpty) {
        stdout.writeln('(no payments)');
        return;
      }
      for (final p in all) {
        stdout.writeln(
          '${p.id}  inv:${p.invoiceNumber}  ${p.method.label}  '
          '${p.amountInCents}c  ${p.reference ?? "—"}',
        );
      }

    case 'add':
      final pos = _positional(args.skip(1).toList());
      if (pos.length < 2) {
        stdout.writeln(
          'usage: payment add <invoice-num> <amount-cents> '
          '[method:<label>] [ref:<text>]',
        );
        return;
      }
      final invNum = int.tryParse(pos[0]);
      final amount = int.tryParse(pos[1]);
      if (invNum == null || amount == null) {
        stdout.writeln('invoice-num and amount must be numbers');
        return;
      }

      final invoice = await _findInvoice(s, invNum);
      if (invoice == null) {
        stdout.writeln('invoice not found');
        return;
      }

      final methodLabel = _named(args, 'method');
      final method = methodLabel == null
          ? PaymentMethod.cash
          : PaymentMethod.values.firstWhere(
              (m) => m.label.toLowerCase() == methodLabel.toLowerCase(),
              orElse: () => throw ArgumentError('unknown method: $methodLabel'),
            );

      final draft = DraftPayment(
        invoiceNumber: invoice.documentNumber,
        method: method,
        amountInCents: amount,
        reference: _named(args, 'ref'),
        date: DateTime.now(),
      );

      final balance =
          await s.invoiceService.balanceCents(invoice.documentNumber);
      final p = await s.repos.payments.commit(draft, balance);
      stdout.writeln('created: ${p.id}  ${p.amountInCents}c');

    case 'show':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: payment show <id>');
        return;
      }
      final id = int.tryParse(pos.first);
      if (id == null) {
        stdout.writeln('id must be a number');
        return;
      }
      final all = await s.repos.payments.findAll();
      final p = all.where((x) => x.id.number == id).firstOrNull;
      if (p == null) {
        stdout.writeln('not found');
        return;
      }
      stdout
        ..writeln('id       : ${p.id}')
        ..writeln('invoice  : ${p.invoiceNumber}')
        ..writeln('amount   : ${p.amountInCents}c')
        ..writeln('method   : ${p.method.label}')
        ..writeln('date     : ${p.date.toIso8601String()}')
        ..writeln('reference: ${p.reference ?? "—"}')
        ..writeln('notes    : ${p.notes ?? "—"}');

    default:
      stdout.writeln('unknown: payment ${args.first}');
  }
}

// ─────────────────────────────────────────────────────────────────────
// receipt
// ─────────────────────────────────────────────────────────────────────

Future<void> _receipt(List<String> args, Services s) async {
  if (args.isEmpty) {
    stdout.writeln('usage: receipt <list|for|pdf> ...');
    return;
  }
  switch (args.first) {
    case 'list':
      final all = await s.repos.receipts.findAll();
      if (all.isEmpty) {
        stdout.writeln('(no receipts)');
        return;
      }
      for (final r in all) {
        stdout.writeln(
          '${r.receiptId}  payment:${r.payment.id}  '
          'invoice:${r.invoice.documentNumber}',
        );
      }

    case 'for':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: receipt for <payment-id>');
        return;
      }
      final pid = int.tryParse(pos.first);
      if (pid == null) {
        stdout.writeln('payment-id must be a number');
        return;
      }
      final payments = await s.repos.payments.findAll();
      final payment = payments.where((p) => p.id.number == pid).firstOrNull;
      if (payment == null) {
        stdout.writeln('payment not found');
        return;
      }
      final invoice = await s.repos.invoices.findByNumber(
        payment.invoiceNumber,
        includeDeleted: true,
      );
      if (invoice == null) {
        stdout.writeln('invoice for payment not found');
        return;
      }
      final receipt = await s.receiptService.forPayment(
        invoice: invoice,
        payment: payment,
      );
      stdout.writeln('receipt: ${receipt.receiptId}');

    case 'pdf':
      final pos = _positional(args.skip(1).toList());
      if (pos.isEmpty) {
        stdout.writeln('usage: receipt pdf <receipt-num>');
        return;
      }
      final num = int.tryParse(pos.first);
      if (num == null) {
        stdout.writeln('receipt-num must be a number');
        return;
      }
      final receipts = await s.repos.receipts.findAll();
      final r = receipts
          .where((x) => x.receiptId.id == num)
          .firstOrNull;
      if (r == null) {
        stdout.writeln('receipt not found');
        return;
      }
      await s.receiptService.saveAsPdf(r);
      stdout.writeln('saved REC_${num.toString().padLeft(4, "0")}.pdf');

    default:
      stdout.writeln('unknown: receipt ${args.first}');
  }
}

// ─────────────────────────────────────────────────────────────────────
// counter (debug)
// ─────────────────────────────────────────────────────────────────────

Future<void> _counter(List<String> args, Services s) async {
  if (args.isEmpty || args.first != 'show') {
    stdout.writeln('usage: counter show');
    return;
  }
  final snap = await s.counterService.snapshot();
  for (final entry in snap.entries) {
    stdout.writeln('${entry.key.id.padRight(10)} : ${entry.value}');
  }
}