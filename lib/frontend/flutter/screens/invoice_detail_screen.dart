import 'package:finance_management_system/frontend/flutter/widgets/payment_icon.dart';
import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/forms/payment_form.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_previewer.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_printer.dart';

/// Coordinator for a single invoice: shows status, details, items,
/// payments, and balances; exposes actions to record payments and
/// generate the PDF.
///
/// Pops with `true` if anything changed (a payment was recorded) so
/// callers — the invoices list, the dashboard — can refresh.
class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Future<_DetailData> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadDetail(widget.invoice);
    });
  }

  Future<void> _recordPayment() async {
    final payment = await Navigator.push<Payment>(
      context,
      MaterialPageRoute(builder: (_) => PaymentForm(invoice: widget.invoice)),
    );
    if (payment != null) {
      _changed = true;
      _reload();
    }
  }

  Future<void> _savePdf() async {
    try {
      await services.invoiceService.saveAsPdf(widget.invoice.documentNumber);
      if (!mounted) return;
      showSuccessSnack(context, 'PDF saved to your documents folder');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  Future<void> _preview() async {
    try {
      await services.invoiceService.preview(
        widget.invoice,
        const FlutterPreviewer(),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  Future<void> _print() async {
    try {
      await services.invoiceService.print(
        widget.invoice,
        const FlutterPrinter(),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${widget.invoice.documentNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _changed),
        ),
      ),
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
    final inv = widget.invoice;
    final currency = inv.business.configuredCurrency;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        _statusCard(data),
        const SizedBox(height: AppSpacing.sectionGap),
        _customerCard(inv),
        const SizedBox(height: AppSpacing.sectionGap),
        _metaSection(inv),
        const SizedBox(height: AppSpacing.sectionGap),
        _itemsSection(inv, currency),
        const SizedBox(height: AppSpacing.sectionGap),
        _totalsSection(data, currency),
        const SizedBox(height: AppSpacing.sectionGap),
        _actionsRow(data),
        const SizedBox(height: AppSpacing.sectionGap),
        _paymentsSection(data, currency),
        if (inv.notes != null && inv.notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          _notesSection(inv.notes!),
        ],
        const SizedBox(height: AppSpacing.screenPadding),
      ],
    );
  }

  // ── Cards / sections ────────────────────────────────────────────

  Widget _statusCard(_DetailData data) {
    final currency = widget.invoice.business.configuredCurrency;
    final (label, color) = _statusFor(data);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$currency ${formatMoney(data.balanceCents)}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _statusFor(_DetailData data) {
    if (data.balanceCents <= 0) return ('PAID', AppTheme.brandGreen);
    if (data.paidCents == 0) return ('UNPAID', Colors.grey.shade700);
    return ('PARTIAL', Colors.orange.shade800);
  }

  Widget _customerCard(Invoice inv) {
    final c = inv.customer;
    return _sectionCard(
      title: 'Customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (c.email != null && c.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              c.email!,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
          if (c.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              c.phoneNumber,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
          if (c.address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              c.address,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaSection(Invoice inv) {
    return _sectionCard(
      title: 'Details',
      child: Column(
        children: [
          _metaRow('Issue date', _formatDate(inv.date)),
          _metaRow('Payment terms', inv.terms.label),
          _metaRow('Due date', _formatDate(inv.dueDate)),
        ],
      ),
    );
  }

  Widget _itemsSection(Invoice inv, String currency) {
    final items = inv.items.toList()
      ..sort((a, b) => a.item.id.number.compareTo(b.item.id.number));

    return _sectionCard(
      title: 'Items',
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _itemRow(items[i], currency),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(InvoiceItem item, String currency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.quantity} × $currency '
                '${formatMoney(item.priceInCents)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currency ${formatMoney(item.lineTotalCents)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _totalsSection(_DetailData data, String currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          _totalsRow('Subtotal', '$currency ${formatMoney(data.totalCents)}'),
          const SizedBox(height: 6),
          _totalsRow('Paid', '$currency ${formatMoney(data.paidCents)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white, height: 1),
          ),
          _totalsRow(
            'Balance due',
            '$currency ${formatMoney(data.balanceCents)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(_DetailData data) {
    final canPay = data.balanceCents > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AsyncButton(
          label: canPay ? 'Record Payment' : 'Fully Paid',
          icon: canPay ? Icons.add_card : Icons.check_circle,
          onPressed: canPay ? _recordPayment : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AsyncButton(
                label: 'Save PDF',
                icon: Icons.picture_as_pdf_outlined,
                filled: false,
                onPressed: _savePdf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _print(),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _preview(),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentsSection(_DetailData data, String currency) {
    if (data.payments.isEmpty) {
      return _sectionCard(
        title: 'Payments',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: EmptyState(
            icon: Icons.payments_outlined,
            message: 'No payments yet',
          ),
        ),
      );
    }

    return _sectionCard(
      title: 'Payments',
      child: Column(
        children: [
          for (var i = 0; i < data.payments.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _paymentRow(data.payments[i], currency),
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(Payment p, String currency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentIcon(payment: p, color: AppTheme.brandGreenDark),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.method.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(p.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              if (p.reference != null && p.reference!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Ref: ${p.reference}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currency ${formatMoney(p.amountInCents)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _notesSection(String notes) {
    return _sectionCard(
      title: 'Notes',
      child: Text(
        notes,
        style: TextStyle(color: Colors.grey.shade800, height: 1.4),
      ),
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

  Widget _totalsRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: AppTheme.brandGreenDark,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
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
  final List<Payment> payments;
  final int totalCents;
  final int paidCents;
  final int balanceCents;

  const _DetailData({
    required this.payments,
    required this.totalCents,
    required this.paidCents,
    required this.balanceCents,
  });
}

Future<_DetailData> _loadDetail(Invoice invoice) async {
  final raw = await services.repos.payments.findByInvoice(
    invoice.documentNumber,
  );
  final payments = raw.toList()..sort((a, b) => b.date.compareTo(a.date));

  final paid = payments.fold<int>(0, (s, p) => s + p.amountInCents);
  final total = invoice.totalCents;
  final balance = total - paid;

  return _DetailData(
    payments: payments,
    totalCents: total,
    paidCents: paid,
    balanceCents: balance,
  );
}
