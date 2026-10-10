import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/frontend/flutter/forms/invoice_form.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Invoice>
  recentInvoices; // This will be where you inject your list of recent invoices

  const HomeScreen({super.key, required this.recentInvoices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Card with button to navigate to InvoiceForm page
            Card(
              elevation: 10,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Create New Invoice')),
                    Expanded(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InvoiceForm(
                                  items: [
                                    //TODO: inject Items
                                  ],
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.blue,
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ListView of recent invoices
            const Text('Recent Invoices'),
            Expanded(
              child: ListView.builder(
                itemCount: recentInvoices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      recentInvoices[index].date.toLocal().toString(),
                    ),
                    subtitle: Text(
                      '${recentInvoices[index].documentNumber} - ${recentInvoices[index].hashCode}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
