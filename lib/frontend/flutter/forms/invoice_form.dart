import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// One editable line on the invoice form. The item is nullable until
/// the user picks one; quantity defaults to 1 and adjusts via the
/// stepper.
class _Line {
  Item? item;
  int quantity;
  // ignore: unused_element_parameter
  _Line({this.item, this.quantity = 1});
}

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();

  Customer? _customer;
  PaymentTerms _terms = PaymentTerms.dueOnReceipt;
  DateTime _date = DateTime.now();
  final List<_Line> _lines = [];

  // Loaded once on init.
  Business? _business;
  List<Customer> _customers = [];
  List<Item> _items = [];
  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final business = await services.repos.businesses.findSingleton();
      final customers =
          (await services.repos.customers.findAll()).toList();
      final items = (await services.repos.items.findAll()).toList();
      if (!mounted) return;
      setState(() {
        _business = business;
        _customers = customers;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  // ── Line management ─────────────────────────────────────────────

  void _addLine() {
    setState(() {
      _lines.add(_Line());
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  void _setItem(int index, Item? item) {
    setState(() {
      _lines[index].item = item;
    });
  }

  void _setQuantity(int index, int quantity) {
    if (quantity < 1) return;
    setState(() {
      _lines[index].quantity = quantity;
    });
  }

  /// Items selectable in the dropdown at [rowIndex]. Excludes items
  /// already used in other rows, plus the item currently selected
  /// in this row (so it stays visible).
  List<Item> _availableItems(int rowIndex) {
    final current = _lines[rowIndex].item;
    final usedElsewhere = <Item>{};
    for (var i = 0; i < _lines.length; i++) {
      if (i == rowIndex) continue;
      final it = _lines[i].item;
      if (it != null) usedElsewhere.add(it);
    }
    return _items
        .where((it) => it == current || !usedElsewhere.contains(it))
        .toList();
  }

  int get _subtotalCents {
    var sum = 0;
    for (final line in _lines) {
      final it = line.item;
      if (it == null) continue;
      sum += it.priceInCents * line.quantity;
    }
    return sum;
  }

  // ── Save ────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_customer == null) {
      showErrorSnack(context, 'Pick a customer');
      return;
    }
    if (_lines.isEmpty) {
      showErrorSnack(context, 'Add at least one item');
      return;
    }
    if (_lines.any((l) => l.item == null)) {
      showErrorSnack(context, 'Every line must have an item selected');
      return;
    }
    final business = _business;
    if (business == null) {
      showErrorSnack(context, 'No business configured');
      return;
    }

    final items = _lines
        .map((l) => InvoiceItem(item: l.item!, quantity: l.quantity))
        .toSet();

    final draft = services.invoiceService.createDraftInvoice(
      business: business,
      customer: _customer!,
      items: items,
      paymentTerms: _terms,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    try {
      final invoice = await services.invoiceService.commit(draft);
      if (!mounted) return;
      showSuccessSnack(context, 'Invoice created');
      Navigator.pop<Invoice>(context, invoice);
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
      appBar: AppBar(title: const Text('New Invoice')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Text('Could not load form data: $_loadError'),
        ),
      );
    }
    if (_business == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            'Set up your business before creating invoices.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            'Add a customer before creating invoices.',
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
          _customerField(),
          const SizedBox(height: 16),
          _termsField(),
          const SizedBox(height: 16),
          _dateField(),
          const SizedBox(height: 16),
          _notesField(),
          const SizedBox(height: AppSpacing.sectionGap),
          _itemsSection(),
          const SizedBox(height: AppSpacing.sectionGap),
          _totalsRow(),
          const SizedBox(height: AppSpacing.sectionGap),
          AsyncButton(
            label: 'Create Invoice',
            icon: Icons.check,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.screenPadding),
        ],
      ),
    );
  }

  Widget _customerField() {
    return DropdownButtonFormField<Customer>(
      initialValue: _customer,
      decoration: const InputDecoration(
        labelText: 'Customer',
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: [
        for (final c in _customers)
          DropdownMenuItem(
            value: c,
            child: Text(c.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (c) => setState(() => _customer = c),
      validator: (v) => v == null ? 'Customer is required' : null,
    );
  }

  Widget _termsField() {
    return DropdownButtonFormField<PaymentTerms>(
      initialValue: _terms,
      decoration: const InputDecoration(
        labelText: 'Payment terms',
        prefixIcon: Icon(Icons.schedule_outlined),
      ),
      items: [
        for (final t in PaymentTerms.values)
          DropdownMenuItem(value: t, child: Text(t.label)),
      ],
      onChanged: (t) {
        if (t != null) setState(() => _terms = t);
      },
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(_date.toIso8601String().split('T').first),
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

  Widget _itemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ],
        ),
        if (_lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No items yet. Tap "Add item" to add a line.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        for (var i = 0; i < _lines.length; i++) ...[
          const SizedBox(height: 8),
          _lineRow(i),
        ],
      ],
    );
  }

  Widget _lineRow(int index) {
    final line = _lines[index];
    final selected = line.item;
    final available = _availableItems(index);
    final lineTotal = selected == null
        ? 0
        : selected.priceInCents * line.quantity;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<Item>(
                    initialValue: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Item',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      for (final it in available)
                        DropdownMenuItem(
                          value: it,
                          child: Text(
                            it.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (it) => _setItem(index, it),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Remove line',
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (selected != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${formatMoney(selected.priceInCents)} / unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Decrease',
                    onPressed: line.quantity > 1
                        ? () => _setQuantity(index, line.quantity - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${line.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Increase',
                    onPressed: () =>
                        _setQuantity(index, line.quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(lineTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _totalsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Text(
            'Subtotal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandGreenDark,
            ),
          ),
          const Spacer(),
          Text(
            formatMoney(_subtotalCents),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}