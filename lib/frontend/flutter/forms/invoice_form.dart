import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/frontend/flutter/widgets/item_card.dart';
import 'package:flutter/material.dart';

class InvoiceForm extends StatefulWidget {
  final int? quantity;
  final List<Item> items;

  const InvoiceForm({super.key, this.quantity, required this.items});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  List<Item> get _items => widget.items;
  late final List<_InvoiceLine> _lines;
  DateTime? _invoiceDate;

  double get _total => _lines.fold(0, (sum, line) => sum + line.lineTotal);

  @override
  void initState() {
    super.initState();
    _lines = [_InvoiceLine()];
    for (var line in _lines) {
      line.quantityController.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  void _addLine() {
    final line = _InvoiceLine();
    line.quantityController.addListener(_refresh);
    _lines.add(line);
    setState(() {});
  }

  void _removeLine(int index) {
    final line = _lines[index];
    line.quantityController.removeListener(_refresh);
    line.quantityController.dispose();
    _lines.removeAt(index);
    setState(() {});
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.quantityController.removeListener(_refresh);
      line.quantityController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _invoiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _invoiceDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Form")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _lines.length; i++) ...[
                      ItemCard(
                        items: _items,
                        onQuantityChanged: (value) {
                          _lines[i].quantityController.text = value.toString();
                          _refresh();
                        },
                        onRemoved: () => _removeLine(i),
                        onItemChanged: (item) {
                          _lines[i].selectedItem = item;
                        },
                      ),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _addLine(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _invoiceDate == null
                            ? 'Select invoice date'
                            : 'Date: ${_invoiceDate!.day}/${_invoiceDate!.month}/${_invoiceDate!.year}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Invoice total: ${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownMenuFormField(
                      label: const Text("Payment Terms"),
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: "Net 5", label: 'net5'),
                        DropdownMenuEntry(value: 'Net 30', label: 'net30'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        final valid = _formKey.currentState!.validate();
                        if (!valid) return;
                        if (_invoiceDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Select an invoice date'),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invoice saved')),
                        );
                      },
                      child: const Text('Save invoice'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceLine {
  final TextEditingController quantityController = TextEditingController();
  Item? selectedItem;

  _InvoiceLine();

  int get lineTotal =>
      (selectedItem?.priceInCents ?? 0) *
      (int.tryParse(quantityController.text) ?? 0);
}
