import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/dialogs.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _resetData() async {
    final ok = await confirm(
      context,
      title: 'Reset all data?',
      message:
          'This permanently deletes your business profile, customers, '
          'items, invoices, payments, receipts, and every PDF the app '
          'has generated.\n\nThis cannot be undone.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (!ok || !mounted) return;

    // Deliberate pause: gives the user a window to change their mind.
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CountdownDialog(seconds: 8),
    );
    if (proceed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _deleteDataFiles();
      await _deleteAppDocuments();
      if (!mounted) return;
      showSuccessSnack(context, 'Data reset. Restart the app to start fresh.');
      Navigator.of(context).popUntil((r) => r.isFirst);

      // after the delete succeeds
      if (Platform.isAndroid || Platform.isIOS) {
        await SystemNavigator.pop();
      } else {
        exit(0);
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteDataFiles() async {
    for (final group in StorageGroup.values) {
      final file = await storage.dataPath(group);
      if (await file.exists()) await file.delete();
      await _deleteIfExists(File('${file.path}.old'));
      await _deleteIfExists(File('${file.path}.tmp'));
    }
  }

  Future<void> _deleteAppDocuments() async {
    final dir = await storage.documentsDirectory();
    if (!await dir.exists()) return;

    final pattern = RegExp(r'^(INV|REC)_\d+\.pdf$', caseSensitive: false);

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (pattern.hasMatch(name)) {
        await entity.delete();
      }
    }
  }

  Future<void> _deleteIfExists(File f) async {
    if (await f.exists()) await f.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _sectionHeader('About'),
          _tile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: 'v0.1.0 · MVP',
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _sectionHeader("Licences"),
          _tile(
            icon: Icons.info_outline,
            title: "Licenses",
            subtitle: 'Open Source Acknowledgements',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Pace',
              applicationVersion: '0.1.0 · MVP',
              applicationLegalese: '© 2026 Venlik',
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _sectionHeader('Data'),
          _tile(
            icon: Icons.delete_forever_outlined,
            title: 'Reset all data',
            subtitle: _busy
                ? 'Resetting…'
                : 'Delete everything and start fresh',
            color: Colors.red.shade700,
            enabled: !_busy,
            onTap: _resetData,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.brandGreenDark),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right, size: 20),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Countdown dialog
// ─────────────────────────────────────────────────────────────────────

/// Modal dialog that counts down from [seconds] to zero, then pops
/// `true`. If the user taps Cancel, pops `false`.
///
/// The countdown is deliberate: it gives the user a window to change
/// their mind after confirming a destructive action, without requiring
/// a second confirmation dialog.
class _CountdownDialog extends StatefulWidget {
  final int seconds;

  const _CountdownDialog({required this.seconds});

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _timer?.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / widget.seconds;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Resetting data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All data will be deleted in:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.red.shade700,
                      ),
                      Text(
                        '$_remaining',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tap Cancel to stop. Otherwise the reset will go '
                    'ahead automatically.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [TextButton(onPressed: _cancel, child: const Text('Cancel'))],
      ),
    );
  }
}
