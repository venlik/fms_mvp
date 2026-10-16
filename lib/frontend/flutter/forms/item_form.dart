import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// Create-or-edit form for a catalog item.
///
/// The price field is a decimal in the UI (e.g. "12.50") but stored
/// as an integer number of cents. Conversion happens at the form
/// boundary so the rest of the app never sees a floating-point price.
class ItemForm extends StatefulWidget {
  final Item? existing;

  const ItemForm({super.key, this.existing});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    final it = widget.existing;
    _name = TextEditingController(text: it?.name ?? '');
    _description = TextEditingController(text: it?.description ?? '');
    _price = TextEditingController(
      text: it == null ? '' : (it.priceInCents / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  int? _parsePriceCents() {
    final raw = _price.text.trim();
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cents = _parsePriceCents();
    if (cents == null) return; // validator already caught this

    final draft = DraftItem(
      name: _name.text.trim(),
      description: _description.text.trim(),
      priceInCents: cents,
    );

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          name: draft.name,
          description: draft.description,
          priceInCents: draft.priceInCents,
        );
        await services.repos.items.update(updated);
      } else {
        await services.repos.items.commit(draft);
      }
      if (!mounted) return;
      showSuccessSnack(
        context,
        _isEditing ? 'Item updated' : 'Item created',
      );
      Navigator.pop(context, true);
    } on DomainError catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'New Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _field(
              controller: _name,
              label: 'Name',
              icon: Icons.inventory_2_outlined,
              required: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            _field(
              controller: _description,
              label: 'Description',
              icon: Icons.notes_outlined,
              required: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLines: 2,
            ),
            _priceField(),
            const SizedBox(height: AppSpacing.sectionGap),
            AsyncButton(
              label: _isEditing ? 'Save changes' : 'Create item',
              icon: Icons.check,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.screenPadding),
          ],
        ),
      ),
    );
  }

  Widget _priceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _save(),
        decoration: const InputDecoration(
          labelText: 'Price',
          prefixIcon: Icon(Icons.attach_money),
          helperText: 'Enter as a decimal, e.g. 12.50',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Price is required';
          }
          final parsed = double.tryParse(value.trim());
          if (parsed == null) return 'Enter a valid number';
          if (parsed <= 0) return 'Price must be greater than 0';
          return null;
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    String? helperText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          helperText: helperText,
          alignLabelWithHint: maxLines > 1,
        ),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}