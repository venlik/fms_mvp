import 'package:finance_management_system/frontend/flutter/screens/invoice_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/forms/invoice_form.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late Future<List<Invoice>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = services.repos.invoices.findAll().then((it) {
        final list = it.toList()..sort((a, b) => b.date.compareTo(a.date));
        return list;
      });
    });
  }

  Future<void> _openForm() async {
    final created = await Navigator.push<Invoice>(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceForm()),
    );
    if (created != null) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'New invoice',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Text('Error: ${snap.error}'),
              ),
            );
          }
          final invoices = snap.data!;
          if (invoices.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No invoices yet',
              actionLabel: 'Create invoice',
              onAction: _openForm,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: invoices.length,
            itemBuilder: (context, i) {
              final inv = invoices[i];
              return Card(
                child: ListTile(
                  title: Text(inv.customer.name),
                  subtitle: Text(
                    '#${inv.documentNumber} · ${inv.terms.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    formatMoney(inv.totalCents),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceDetailScreen(invoice: inv),
                      ),
                    );
                    if (changed == true) _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
