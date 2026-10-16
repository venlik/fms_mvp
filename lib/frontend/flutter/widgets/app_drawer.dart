import 'dart:typed_data' show Uint8List;

import 'package:finance_management_system/backend/storage/business_logo_x.dart';
import 'package:finance_management_system/frontend/flutter/forms/business_form.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_logo_store.dart';
import 'package:finance_management_system/frontend/flutter/screens/documents_screen.dart';
import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/screens/customers_screen.dart';
import 'package:finance_management_system/frontend/flutter/screens/invoices_screen.dart';
import 'package:finance_management_system/frontend/flutter/screens/items_screen.dart';
import 'package:finance_management_system/frontend/flutter/screens/payments_screen.dart';
import 'package:finance_management_system/frontend/flutter/screens/settings_screen.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BusinessHeader(),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.tileGap),
            _entry(
              context,
              Icons.receipt_long_outlined,
              'Invoices',
              () => const InvoicesScreen(),
            ),
            _entry(
              context,
              Icons.payments_outlined,
              'Payments',
              () => const PaymentsScreen(),
            ),
            _entry(
              context,
              Icons.people_outline,
              'Customers',
              () => const CustomersScreen(),
            ),
            _entry(
              context,
              Icons.inventory_2_outlined,
              'Items',
              () => const ItemsScreen(),
            ),
            _entry(
              context,
              Icons.folder_outlined,
              'Documents',
              () => const DocumentsScreen(),
            ),
            const Spacer(),
            const Divider(height: 1),
            _entry(
              context,
              Icons.settings_outlined,
              'Settings',
              () => const SettingsScreen(),
            ),
            const _VersionFooter(),
          ],
        ),
      ),
    );
  }

  Widget _entry(
    BuildContext context,
    IconData icon,
    String label,
    Widget Function() builder,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => builder()));
      },
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Business>(
      future: services.repos.businesses.findSingleton(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _HeaderSkeleton();
        }
        if (snap.hasError || !snap.hasData) {
          return _HeaderEmpty();
        }
        return _HeaderFilled(business: snap.data!);
      },
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEEEEE)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  height: 12,
                  width: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderEmpty extends StatelessWidget {
  const _HeaderEmpty();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      leading: const CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.surfaceGreenTint,
        child: Icon(Icons.storefront_outlined, color: AppTheme.brandGreenDark),
      ),
      title: const Text(
        'Set up your business',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Tap to add your details'),
      onTap: () async {
        Navigator.pop(context);
        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const BusinessForm()),
        );
        if (saved == true) {
          // The drawer's FutureBuilder will refetch on next open.
        }
      },
    );
  }
}

class _HeaderFilled extends StatefulWidget {
  final Business business;
  const _HeaderFilled({required this.business});

  @override
  State<_HeaderFilled> createState() => _HeaderFilledState();
}

class _HeaderFilledState extends State<_HeaderFilled> {
  late final Future<Uint8List?> _logo = widget.business.resolveLogoBytes(
    const FlutterLogoStore(),
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      leading: FutureBuilder<Uint8List?>(
        future: _logo,
        builder: (context, snap) {
          final bytes = snap.data;
          if (bytes != null && bytes.isNotEmpty) {
            return CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.surfaceGreenTint,
              backgroundImage: MemoryImage(bytes),
            );
          }
          return CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.surfaceGreenTint,
            child: Text(
              _initial(),
              style: const TextStyle(
                color: AppTheme.brandGreenDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
      title: Text(
        widget.business.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.business.email, overflow: TextOverflow.ellipsis),
      onTap: () async {
        Navigator.pop(context);
        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessForm(existing: widget.business),
          ),
        );
        if (saved == true) {
          // Refetch on next drawer open.
        }
      },
    );
  }

  String _initial() {
    final name = widget.business.name.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
      ),
      child: Text(
        'v0.1.0 · MVP',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
  }
}
