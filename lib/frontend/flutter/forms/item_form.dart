import 'package:flutter/material.dart';

class ItemForm extends StatefulWidget {
  final String? name;
  final String? description;
  final int? priceInCents;
  final String? notes;
  final Function(
    String name,
    String description,
    int priceInCents,
    String? notes,
  )?
  onSubmit;

  const ItemForm({
    super.key,
    this.name,
    this.description,
    this.priceInCents,
    this.notes,
    this.onSubmit,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemNameController.text = widget.name ?? '';
    _itemDescriptionController.text = widget.description ?? '';
    _itemPriceController.text = (widget.priceInCents ?? '').toString();
    _itemNotesController.text = widget.notes ?? '';
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    _itemNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _itemDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _itemPriceController,
                  decoration: InputDecoration(
                    labelText: 'Price (max 2 decimal places)',
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    //   restrictsTextSelection: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _itemNotesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter some notes';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                      final itemName = _itemNameController.text;
                      final itemDescription = _itemDescriptionController.text;
                      final itemPrice =
                          double.tryParse(_itemPriceController.text) ?? 0.0;
                      final itemNotes = _itemNotesController.text;

                      // Perform form submission logic here
                      print('Submitted Item Form:');
                      print('Item Name: $itemName');
                      print('Description: $itemDescription');
                      print('Price: $itemPrice');
                      print('Notes: $itemNotes');
                      widget.onSubmit?.call(
                        itemName,
                        itemDescription,
                        itemPrice.toInt(),
                        itemNotes,
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
