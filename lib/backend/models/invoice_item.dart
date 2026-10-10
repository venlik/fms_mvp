import 'package:finance_management_system/backend/models/item.dart';

class InvoiceItem {
  final Item item;
  final int quantity;

  InvoiceItem({required this.item, required this.quantity}) {
    if (quantity < 1) {
      throw Exception('Quantity must be >= 1: quantity = $quantity');
    }
  }

  String get itemId => item.id.value;
  String get name => item.name;
  String get description => item.description;
  int get priceInCents => item.priceInCents;
  int get lineTotalCents => priceInCents * quantity;

  InvoiceItem copyWith({Item? item, int? quantity}) {
    return InvoiceItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItem && other.item == item && other.quantity == quantity;
  @override
  int get hashCode => item.hashCode ^ quantity.hashCode << 10;
}
