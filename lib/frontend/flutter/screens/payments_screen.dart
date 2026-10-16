import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/screens/payment_detail_screen.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/payment_icon.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<_PaymentsData> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadPayments();
    });
  }

  Future<void> _openDetail(Payment payment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentDetailScreen(payment: payment),
      ),
    );
    // Detail is read-only for now, but reload in case a future
    // version adds actions that change state.
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: FutureBuilder<_PaymentsData>(
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
          final data = snap.data!;
          if (data.payments.isEmpty) {
            return const EmptyState(
              icon: Icons.payments_outlined,
              message:
                  'No payments yet.\nRecord one from an invoice to see it here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(
              top: AppSpacing.tileGap,
              bottom: AppSpacing.screenPadding,
            ),
            itemCount: data.payments.length,
            itemBuilder: (context, i) {
              final p = data.payments[i];
              return Card(
                child: ListTile(
                  leading: PaymentIcon(
                    payment: p,
                    color: AppTheme.brandGreenDark,
                  ),
                  title: Text(
                    '${p.method.label} · #${p.invoiceNumber}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    p.reference != null && p.reference!.isNotEmpty
                        ? '${_formatDate(p.date)} · Ref: ${p.reference}'
                        : _formatDate(p.date),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${data.currency} ${formatMoney(p.amountInCents)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _openDetail(p),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentsData {
  final List<Payment> payments;
  final String currency;

  const _PaymentsData({required this.payments, required this.currency});
}

Future<_PaymentsData> _loadPayments() async {
  // Fetch business for currency — defaults to KES if unset.
  String currency = 'KES';
  try {
    final business = await services.repos.businesses.findSingleton();
    currency = business.configuredCurrency;
  } catch (_) {
    // No business yet — keep the default.
  }

  final raw = await services.repos.payments.findAll();
  final payments = raw.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return _PaymentsData(payments: payments, currency: currency);
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}