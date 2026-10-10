import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/utils/input_formatter.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final List<Item> items;
  final void Function(int value) onQuantityChanged;
  final void Function(Item item) onItemChanged;
  final void Function() onRemoved;

  const ItemCard({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onRemoved,
    required this.onItemChanged,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Item? selectedItem;
  int quantity = 1; //default quantity = 1

  @override
  void initState() {
    super.initState();
  }

  void _refresh() {
    setState(() {});
  }

  void _onItemChanged() {
    if (selectedItem == null) return;
    widget.onItemChanged(selectedItem!);
    widget.onQuantityChanged(quantity);
    _refresh();
  }

  void _updateQuantity(int? newQuantity) {
    if (selectedItem == null) return;
    if (quantity < 1) {
      quantity = newQuantity ?? 1;
    } else {
      newQuantity == null ? quantity++ : quantity = newQuantity;
      widget.onQuantityChanged(quantity);
      _refresh();
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
      widget.onQuantityChanged(quantity);
      _refresh();
    }
  }

  void _onRemoved() => widget.onRemoved();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            DropdownMenu(
              onSelected: (newItem) {
                if (newItem == null) return;
                selectedItem = newItem;
                _onItemChanged();
              },
              width: double.infinity,
              dropdownMenuEntries: widget.items
                  .map(
                    (item) => DropdownMenuEntry(value: item, label: item.name),
                  )
                  .toList(),
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedItem?.name} x $quantity',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.redAccent),
                  onPressed: _decreaseQuantity,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingInputFormatter(
                        RegExp(r'^\d{0,4}$'),
                        allowed: true,
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Quantity (e.g. 100)',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      _updateQuantity(int.parse(value));
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.greenAccent),
                  onPressed: () => _updateQuantity(null),
                ),
              ],
            ),
            Text(
              '\$${selectedItem?.priceInCents} / Item',
              style: TextStyle(fontSize: 14),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Line Total: \$${((selectedItem?.priceInCents ?? 0) * quantity).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _onRemoved(),

                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                  ),
                  child: Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
