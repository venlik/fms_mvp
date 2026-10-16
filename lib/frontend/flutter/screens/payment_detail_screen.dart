import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/screens/invoice_detail_screen.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/payment_icon.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_previewer.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_printer.dart';

/// Read-only view of a single payment, plus actions that operate on it:
/// navigate to the parent invoice, generate the receipt PDF.
class PaymentDetailScreen extends StatefulWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late Future<_DetailData> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadDetail(widget.payment);
    });
  }

  Future<void> _viewInvoice(Invoice invoice) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: invoice)),
    );
  }

  Future<void> _saveReceipt(Invoice invoice) async {
    try {
      final receipt = await services.receiptService.forPayment(
        invoice: invoice,
        payment: widget.payment,
      );

      await services.receiptService.saveAsPdf(receipt);
      if (!mounted) return;
      showSuccessSnack(context, 'Receipt saved to your documents folder');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  Future<void> _previewReceipt(Invoice invoice) async {
    try {
      final receipt = await services.receiptService.forPayment(
        invoice: invoice,
        payment: widget.payment,
      );
      await services.receiptService.preview(receipt, const FlutterPreviewer());
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  Future<void> _printReceipt(Invoice invoice) async {
    try {
      final receipt = await services.receiptService.forPayment(
        invoice: invoice,
        payment: widget.payment,
      );
      await services.receiptService.print(receipt, const FlutterPrinter());
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: FutureBuilder<_DetailData>(
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
          return _body(snap.data!);
        },
      ),
    );
  }

  Widget _body(_DetailData data) {
    final p = widget.payment;
    final currency = data.currency;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        _amountCard(p, currency),
        const SizedBox(height: AppSpacing.sectionGap),
        _detailsCard(p),
        const SizedBox(height: AppSpacing.sectionGap),
        _appliedToCard(data),
        const SizedBox(height: AppSpacing.sectionGap),
        _actionsSection(data),
        const SizedBox(height: AppSpacing.screenPadding),
      ],
    );
  }

  Widget _amountCard(Payment p, String currency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppTheme.brandGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          PaymentIcon(payment: p, size: 32, color: AppTheme.brandGreenDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currency ${formatMoney(p.amountInCents)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandGreenDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${p.method.label} · ${_formatDate(p.date)}',
                  style: const TextStyle(
                    color: AppTheme.brandGreenDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(Payment p) {
    return _sectionCard(
      title: 'Details',
      child: Column(
        children: [
          _metaRow('Method', p.method.label),
          _metaRow('Date', _formatDate(p.date)),
          _metaRow(
            'Reference',
            p.reference != null && p.reference!.isNotEmpty ? p.reference! : '—',
          ),
          _metaRow(
            'Notes',
            p.notes != null && p.notes!.isNotEmpty ? p.notes! : '—',
          ),
        ],
      ),
    );
  }

  Widget _appliedToCard(_DetailData data) {
    final inv = data.invoice;
    if (inv == null) {
      return _sectionCard(
        title: 'Applied to',
        child: Text(
          'Invoice #${widget.payment.invoiceNumber} not found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final currency = data.currency;
    return _sectionCard(
      title: 'Applied to',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: AppTheme.brandGreenDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice #${inv.documentNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.customer.name,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Current invoice balance',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '$currency ${formatMoney(data.invoiceBalanceCents)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionsSection(_DetailData data) {
    final inv = data.invoice;
    if (inv == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AsyncButton(
          label: 'View Invoice',
          icon: Icons.receipt_long_outlined,
          filled: false,
          onPressed: () => _viewInvoice(inv),
        ),
        const SizedBox(height: 10),
        AsyncButton(
          label: 'Save Receipt',
          icon: Icons.picture_as_pdf_outlined,
          onPressed: () => _saveReceipt(inv),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previewReceipt(inv),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printReceipt(inv),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared ──────────────────────────────────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────

class _DetailData {
  final Invoice? invoice;
  final int invoiceBalanceCents;
  final String currency;

  const _DetailData({
    required this.invoice,
    required this.invoiceBalanceCents,
    required this.currency,
  });
}

Future<_DetailData> _loadDetail(Payment payment) async {
  String currency = 'KES';
  try {
    final business = await services.repos.businesses.findSingleton();
    currency = business.configuredCurrency;
  } catch (_) {
    // No business yet — keep the default.
  }

  Invoice? invoice;
  int balance = 0;

  try {
    invoice = await services.repos.invoices.findByNumber(
      payment.invoiceNumber,
      includeDeleted: true,
    );
    if (invoice != null) {
      balance = await services.invoiceService.balanceCents(
        payment.invoiceNumber,
      );
    }
  } catch (_) {
    // Invoice gone or unreadable — leave both null / zero.
  }

  return _DetailData(
    invoice: invoice,
    invoiceBalanceCents: balance,
    currency: currency,
  );
}
