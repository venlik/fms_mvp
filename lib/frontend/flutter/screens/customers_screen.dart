import 'package:flutter/material.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/forms/customer_form.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:finance_management_system/frontend/flutter/widgets/dialogs.dart';
import 'package:finance_management_system/frontend/flutter/widgets/empty_state.dart';
import 'package:finance_management_system/frontend/flutter/widgets/snacks.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<List<Customer>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = services.repos.customers.findAll().then((it) => it.toList());
    });
  }

  Future<void> _openForm({Customer? existing}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CustomerForm(existing: existing)),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(Customer customer) async {
    final ok = await confirm(
      context,
      title: 'Delete customer',
      message:
          'Remove ${customer.name} from your customer list? '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;

    try {
      await services.repos.customers.softDelete(customer.id);
      if (!mounted) return;
      showSuccessSnack(context, 'Customer deleted');
      _reload();
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Add customer',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Customer>>(
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
          final customers = snap.data!;
          if (customers.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              message: 'No customers yet',
              actionLabel: 'Add customer',
              onAction: () => _openForm(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: customers.length,
            itemBuilder: (context, i) {
              final c = customers[i];
              return Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text(
                    c.phoneNumber +
                        (c.email != null && c.email!.isNotEmpty
                            ? ' · ${c.email}'
                            : ''),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openForm(existing: c),
                  trailing: PopupMenuButton<_RowAction>(
                    tooltip: 'Actions',
                    onSelected: (action) {
                      switch (action) {
                        case _RowAction.edit:
                          _openForm(existing: c);
                        case _RowAction.delete:
                          _delete(c);
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
