import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

/// Lists PDFs the app has generated — invoices and receipts — from
/// the documents directory. Read-only; tap a row to open it with the
/// platform's default PDF handler.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<_DocEntry>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadDocuments();
    });
  }

  Future<void> _open(_DocEntry entry) async {
    try {
      await documentOpener.open(entry.file.path);
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<_DocEntry>>(
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
          final docs = snap.data!;
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_outlined,
              message:
                  'No documents yet.\n'
                  'Save an invoice or receipt PDF and it will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(
              top: AppSpacing.tileGap,
              bottom: AppSpacing.screenPadding,
            ),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              return Card(
                child: ListTile(
                  leading: Icon(
                    doc.isReceipt
                        ? Icons.receipt_outlined
                        : Icons.description_outlined,
                    color: AppTheme.brandGreenDark,
                  ),
                  title: Text(
                    doc.file.uri.pathSegments.last,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_formatSize(doc.sizeBytes)} · ${_formatDate(doc.modified)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(doc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────

class _DocEntry {
  final File file;
  final int sizeBytes;
  final DateTime modified;
  final bool isReceipt;

  const _DocEntry({
    required this.file,
    required this.sizeBytes,
    required this.modified,
    required this.isReceipt,
  });
}

/// Matches the two filename patterns the app produces:
///   INV_0001.pdf   — invoice PDFs
///   REC_0001.pdf   — receipt PDFs
final _invoicePattern = RegExp(r'^INV_\d+\.pdf$', caseSensitive: false);
final _receiptPattern = RegExp(r'^REC_\d+\.pdf$', caseSensitive: false);

Future<List<_DocEntry>> _loadDocuments() async {
  final dir = await storage.documentsDirectory();
  if (!await dir.exists()) return const [];

  final entries = <_DocEntry>[];
  await for (final entity in dir.list(followLinks: false)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;

    final isInvoice = _invoicePattern.hasMatch(name);
    final isReceipt = _receiptPattern.hasMatch(name);
    if (!isInvoice && !isReceipt) continue;

    final stat = await entity.stat();
    entries.add(
      _DocEntry(
        file: entity,
        sizeBytes: stat.size,
        modified: stat.modified,
        isReceipt: isReceipt,
      ),
    );
  }

  // Newest first.
  entries.sort((a, b) => b.modified.compareTo(a.modified));
  return entries;
}

// ─────────────────────────────────────────────────────────────────────
// Formatting
// ─────────────────────────────────────────────────────────────────────

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$m';
}
