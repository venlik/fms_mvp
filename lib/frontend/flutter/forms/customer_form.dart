import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// Create-or-edit form for a customer.
///
/// If [existing] is null, commits a new customer. Otherwise the fields
/// are pre-filled and saving replaces the existing record in place.
///
/// Returns `true` from `Navigator.pop` on successful save so the list
/// screen can refresh.
class CustomerForm extends StatefulWidget {
  final Customer? existing;

  const CustomerForm({super.key, this.existing});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _phone = TextEditingController(text: c?.phoneNumber ?? '');
    _email = TextEditingController(text: c?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = DraftCustomer(
      name: _name.text.trim(),
      address: _address.text.trim(),
      phoneNumber: _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
    );

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          name: draft.name,
          address: draft.address,
          phoneNumber: draft.phoneNumber,
          email: draft.email,
        );
        await services.repos.customers.update(updated);
      } else {
        await services.repos.customers.commit(draft);
      }
      if (!mounted) return;
      showSuccessSnack(
        context,
        _isEditing ? 'Customer updated' : 'Customer created',
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
        title: Text(_isEditing ? 'Edit Customer' : 'New Customer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _field(
              controller: _name,
              label: 'Name',
              icon: Icons.person_outline,
              required: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            _field(
              controller: _phone,
              label: 'Phone',
              icon: Icons.phone_outlined,
              required: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            _field(
              controller: _email,
              label: 'Email',
              icon: Icons.email_outlined,
              required: false,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              helperText: 'Optional',
            ),
            _field(
              controller: _address,
              label: 'Address',
              icon: Icons.location_on_outlined,
              required: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            AsyncButton(
              label: _isEditing ? 'Save changes' : 'Create customer',
              icon: Icons.check,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.screenPadding),
          ],
        ),
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
          if (!required) {
            if (label == 'Email' &&
                value != null &&
                value.isNotEmpty &&
                !value.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          }
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}