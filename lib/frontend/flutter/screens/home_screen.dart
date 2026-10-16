import 'package:finance_management_system/frontend/flutter/forms/customer_form.dart';
import 'package:finance_management_system/frontend/flutter/screens/invoice_detail_screen.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/app_drawer.dart';
import 'package:finance_management_system/frontend/flutter/forms/invoice_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorBody(error: snap.error.toString(), onRetry: _reload);
          }
          return _DashboardBody(data: snap.data!, onRefresh: _reload);
        },
      ),
    );
  }
}

class _DashboardData {
  final Business? business;
  final int outstandingCents;
  final int paidCents;
  final int invoiceCount;
  final int customerCount;
  final String currency;
  final List<Invoice> recentInvoices;

  const _DashboardData({
    required this.business,
    required this.outstandingCents,
    required this.paidCents,
    required this.invoiceCount,
    required this.customerCount,
    required this.currency,
    required this.recentInvoices,
  });
}

Future<_DashboardData> _loadDashboard() async {
  Business? business;
  try {
    business = await services.repos.businesses.findSingleton();
  } catch (_) {
    business = null;
  }

  final invoices = (await services.repos.invoices.findAll()).toList();
  final payments = (await services.repos.payments.findAll()).toList();
  final customers = (await services.repos.customers.findAll()).toList();

  final totalCents = invoices.fold<int>(0, (s, i) => s + i.totalCents);
  final paidCents = payments.fold<int>(0, (s, p) => s + p.amountInCents);

  final recent = <Invoice>[...invoices]
    ..sort((a, b) => b.date.compareTo(a.date));
  final recentFive = recent.take(5).toList();

  return _DashboardData(
    business: business,
    outstandingCents: totalCents - paidCents,
    paidCents: paidCents,
    invoiceCount: invoices.length,
    customerCount: customers.length,
    currency: business?.configuredCurrency ?? 'KES',
    recentInvoices: recentFive,
  );
}

class _DashboardBody extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onRefresh;

  const _DashboardBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _StatCard(
            currency: data.currency,
            outstandingCents: data.outstandingCents,
            invoiceCount: data.invoiceCount,
            customerCount: data.customerCount,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _QuickActions(onSaved: onRefresh),
          const SizedBox(height: AppSpacing.sectionGap),
          _RecentInvoices(invoices: data.recentInvoices, onRefresh: onRefresh),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String currency;
  final int outstandingCents;
  final int invoiceCount;
  final int customerCount;

  const _StatCard({
    required this.currency,
    required this.outstandingCents,
    required this.invoiceCount,
    required this.customerCount,
  });

  @override
  Widget build(BuildContext context) {
    final negative = outstandingCents < 0;
    final display = negative ? -outstandingCents : outstandingCents;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppTheme.brandGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            negative ? 'Overpaid' : 'Outstanding',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.brandGreenDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currency ${formatMoney(display)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandGreenDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(
                '$invoiceCount ${invoiceCount == 1 ? "invoice" : "invoices"}',
              ),
              const SizedBox(width: 8),
              _chip(
                '$customerCount ${customerCount == 1 ? "customer" : "customers"}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppTheme.brandGreenDark),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onSaved;

  const _QuickActions({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final created = await Navigator.push<Invoice>(
                context,
                MaterialPageRoute(builder: (_) => const InvoiceForm()),
              );
              if (created != null) onSaved();
            },
            icon: const Icon(Icons.add),
            label: const Text('New Invoice'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final saved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CustomerForm()),
              );
              if (saved == true) onSaved();
            },
            icon: const Icon(Icons.person_add_alt),
            label: const Text('New Customer'),
          ),
        ),
      ],
    );
  }
}

class _RecentInvoices extends StatelessWidget {
  final List<Invoice> invoices;
  final VoidCallback onRefresh;

  const _RecentInvoices({required this.invoices, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No invoices yet. Create your first one to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent invoices',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...invoices.map(
          (inv) => Card(
            child: ListTile(
              title: Text(inv.customer.name),
              subtitle: Text('#${inv.documentNumber}'),
              trailing: Text(
                '${inv.business.configuredCurrency} '
                '${formatMoney(inv.totalCents)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoiceDetailScreen(invoice: inv),
                  ),
                );
                if (changed == true) onRefresh();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Could not load dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
