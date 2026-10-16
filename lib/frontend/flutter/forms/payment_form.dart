import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/drafts/draft_payment.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// Records a payment against [invoice].
///
/// The invoice is fixed — the user can't redirect a payment to a
/// different invoice mid-form (mirrors `DraftPayment`'s contract).
///
/// Returns the created [Payment] from `Navigator.pop` on success.
class PaymentForm extends StatefulWidget {
  final Invoice invoice;

  const PaymentForm({super.key, required this.invoice});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();

  PaymentMethod _method = PaymentMethod.cash;

  /// The date shown in the field. Initialized once and updated only
  /// when the user picks a different date.
  late DateTime _displayedDate;

  /// Null until the user touches the date picker. When non-null, this
  /// wins over `DateTime.now()` at save time.
  DateTime? _userPickedDate;

  int _balanceCents = 0;
  bool _loadingBalance = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _displayedDate = DateTime.now();
    _loadBalance();
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────

  Future<void> _loadBalance() async {
    try {
      final balance = await services.invoiceService.balanceCents(
        widget.invoice.documentNumber,
      );
      if (!mounted) return;
      setState(() {
        _balanceCents = balance;
        _loadingBalance = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loadingBalance = false;
      });
    }
  }

  // ── Date ────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _userPickedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _userPickedDate = picked;
      _displayedDate = picked;
    });
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

  // ── Reference ───────────────────────────────────────────────────

  bool get _needsReference => _method != PaymentMethod.cash;

  String get _referenceLabel {
    switch (_method) {
      case PaymentMethod.mpesa:
        return 'M-Pesa code';
      case PaymentMethod.card:
        return 'Card transaction ID';
      case PaymentMethod.bankTransfer:
        return 'Bank reference';
      case PaymentMethod.cheque:
        return 'Cheque number';
      case PaymentMethod.other:
        return 'Reference';
      case PaymentMethod.cash:
        return 'Reference'; // unreachable, kept exhaustive
    }
  }

  // ── Amount ──────────────────────────────────────────────────────

  int? _parseAmountCents() {
    final raw = _amount.text.trim();
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  // ── Save ────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amountCents = _parseAmountCents();
    if (amountCents == null) return; // validator already caught this

    final draft = DraftPayment(
      invoiceNumber: widget.invoice.documentNumber,
      method: _method,
      amountInCents: amountCents,
      reference: _needsReference ? _reference.text.trim() : null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      date: _userPickedDate ?? DateTime.now(),
    );

    try {
      final payment = await services.repos.payments.commit(
        draft,
        _balanceCents,
      );
      if (!mounted) return;
      showSuccessSnack(context, 'Payment recorded');
      Navigator.pop<Payment>(context, payment);
    } on DomainError catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loadingBalance) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Text('Could not load balance: $_loadError'),
        ),
      );
    }
    if (_balanceCents <= 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            'This invoice is already fully paid.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _summaryCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _amountField(),
          const SizedBox(height: 16),
          _methodField(),
          if (_needsReference) ...[
            const SizedBox(height: 16),
            _referenceField(),
          ],
          const SizedBox(height: 16),
          _dateField(),
          const SizedBox(height: 16),
          _notesField(),
          const SizedBox(height: AppSpacing.sectionGap),
          AsyncButton(
            label: 'Record payment',
            icon: Icons.check,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.screenPadding),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final inv = widget.invoice;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.brandGreenDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Invoice #${inv.documentNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.brandGreenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            inv.customer.name,
            style: const TextStyle(color: AppTheme.brandGreenDark),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Balance due',
                style: TextStyle(
                  color: AppTheme.brandGreenDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                formatMoney(_balanceCents),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandGreenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixIcon: Icon(Icons.attach_money),
        helperText: 'Enter as a decimal, e.g. 150.00',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Amount is required';
        }
        final parsed = double.tryParse(value.trim());
        if (parsed == null) return 'Enter a valid number';
        if (parsed <= 0) return 'Amount must be greater than 0';

        final cents = (parsed * 100).round();
        if (cents > _balanceCents) {
          return 'Exceeds balance of ${formatMoney(_balanceCents)}';
        }
        return null;
      },
    );
  }

  Widget _methodField() {
    return DropdownButtonFormField<PaymentMethod>(
      initialValue: _method,
      decoration: const InputDecoration(
        labelText: 'Payment method',
        prefixIcon: Icon(Icons.payments_outlined),
      ),
      items: [
        for (final m in PaymentMethod.values)
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m == null) return;
        setState(() => _method = m);
      },
    );
  }

  Widget _referenceField() {
    return TextFormField(
      controller: _reference,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: _referenceLabel,
        prefixIcon: const Icon(Icons.tag),
      ),
      validator: (value) {
        if (!_needsReference) return null;
        if (value == null || value.trim().isEmpty) {
          return '$_referenceLabel is required';
        }
        return null;
      },
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          helperText: 'Tap to change',
        ),
        child: Text(_formatDate(_displayedDate)),
      ),
    );
  }

  Widget _notesField() {
    return TextFormField(
      controller: _notes,
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Notes',
        prefixIcon: Icon(Icons.notes_outlined),
        helperText: 'Optional',
        alignLabelWithHint: true,
      ),
    );
  }
}
