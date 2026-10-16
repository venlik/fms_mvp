import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/drafts/draft_business.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/logo.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/async_button.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// The fallback logo used when a business doesn't have one yet.
/// Must match a path registered in pubspec.yaml under `flutter: assets:`.
const _defaultLogo = Logo(
  path: 'assets/logo.jpg',
  source: Source.asset,
);

/// Create-or-edit form for the app's single business profile.
///
/// If [existing] is null, this is the first-run flow: on save, a new
/// business is committed. Otherwise the fields are pre-filled and
/// saving replaces the existing record in place.
///
/// Returns `true` from `Navigator.pop` on successful save so callers
/// can refresh their data.
class BusinessForm extends StatefulWidget {
  final Business? existing;

  const BusinessForm({super.key, this.existing});

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _serviceLocation;
  late final TextEditingController _currency;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _name = TextEditingController(text: b?.name ?? '');
    _phone = TextEditingController(text: b?.phoneNumber ?? '');
    _email = TextEditingController(text: b?.email ?? '');
    _serviceLocation = TextEditingController(text: b?.serviceLocation ?? '');
    _currency = TextEditingController(text: b?.configuredCurrency ?? 'KES');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _serviceLocation.dispose();
    _currency.dispose();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────

  bool get _isEditing => widget.existing != null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = DraftBusiness(
      name: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      email: _email.text.trim(),
      serviceLocation: _serviceLocation.text.trim(),
      configuredCurrency: _currency.text.trim().toUpperCase(),
      logo: widget.existing?.logo ?? _defaultLogo,
    );

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          name: draft.name,
          phoneNumber: draft.phoneNumber,
          email: draft.email,
          serviceLocation: draft.serviceLocation,
          configuredCurrency: draft.configuredCurrency,
           logo: draft.logo
        );
        await services.repos.businesses.update(updated);
      } else {
        await services.repos.businesses.commit(draft);
      }
      if (!mounted) return;
      showSuccessSnack(
        context,
        _isEditing ? 'Business updated' : 'Business created',
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

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Business' : 'Set Up Business'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _intro(),
            const SizedBox(height: AppSpacing.sectionGap),
            _field(
              controller: _name,
              label: 'Business name',
              icon: Icons.storefront_outlined,
              required: true,
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
              required: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            _field(
              controller: _serviceLocation,
              label: 'Service location',
              icon: Icons.location_on_outlined,
              required: true,
              textInputAction: TextInputAction.next,
            ),
            _field(
              controller: _currency,
              label: 'Currency code',
              icon: Icons.attach_money,
              required: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              helperText: 'Three-letter code, e.g. KES, USD, EUR',
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            AsyncButton(
              label: _isEditing ? 'Save changes' : 'Create business',
              icon: Icons.check,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.screenPadding),
          ],
        ),
      ),
    );
  }

  Widget _intro() {
    if (_isEditing) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreenTint,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.brandGreenDark),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'These details appear on every invoice and receipt you issue.',
              style: TextStyle(color: AppTheme.brandGreenDark),
            ),
          ),
        ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          helperText: helperText,
        ),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
