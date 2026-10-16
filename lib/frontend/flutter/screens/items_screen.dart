import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/forms/item_form.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/dialogs.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/money_text.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late Future<(List<Item>, String)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Item>, String)> _load() async {
    String currency = 'KES';
    try {
      final b = await services.repos.businesses.findSingleton();
      currency = b.configuredCurrency;
    } catch (_) {}
    final items = (await services.repos.items.findAll()).toList();
    return (items, currency);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openForm({Item? existing}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemForm(existing: existing)),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(Item item) async {
    final ok = await confirm(
      context,
      title: 'Delete item',
      message:
          'Remove "${item.name}" from your catalog? '
          'Existing invoices will keep referring to it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;

    try {
      await services.repos.items.remove(item.id);
      if (!mounted) return;
      showSuccessSnack(context, 'Item deleted');
      _reload();
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<(List<Item>, String)>(
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
          final (items, currency) = snap.data!;
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No items yet',
              actionLabel: 'Add item',
              onAction: () => _openForm(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              return Card(
                child: ListTile(
                  title: Text(it.name),
                  subtitle: Text(
                    it.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MoneyText(
                        cents: it.priceInCents,
                        currency: currency,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      PopupMenuButton<_RowAction>(
                        tooltip: 'Actions',
                        onSelected: (action) {
                          switch (action) {
                            case _RowAction.edit:
                              _openForm(existing: it);
                            case _RowAction.delete:
                              _delete(it);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _RowAction.edit,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: _RowAction.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _openForm(existing: it),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum _RowAction { edit, delete }