import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/identifier.dart'
    show IdentifierExtras;
import 'package:finance_management_system/backend/models/item.dart';

/// Line items reference live catalog entries. Prices and descriptions
/// are read from the current [Item], not captured at issue time.
///
/// Consequence: if an item's price or description changes after an
/// invoice is issued, regenerating that invoice's PDF will show the
/// new values, not the original ones.
///
/// v1 accepts this. The saved PDF from issue time is the artifact of
/// record; regeneration is best-effort.
///
/// A future version may snapshot item details onto InvoiceItem at
/// issue time. See the manual-tests doc for the deliberate decision
/// and how to migrate.
class InvoiceItem {
  final Item item;
  final int quantity;

  InvoiceItem({required this.item, required this.quantity}) {
    if (quantity < 1) {
      throw InvalidState('Quantity must be >= 1: quantity = $quantity');
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
      identical(this, other) || other is InvoiceItem && other.item == item;
  @override
  int get hashCode => item.hashCode;
}
