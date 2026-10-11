import 'package:finance_management_system/backend/details/item_details_comparison.dart';
import 'package:finance_management_system/backend/models/identifier.dart';

/// A catalog entry — a product or service that can appear on many
/// invoices with different quantities. Identity is [id]; equality and
/// hashing are based on it.
class Item with ItemDetailsComparison implements Entity {
  final Identifier<Item> id;
  @override
  final String name;
  @override
  final String description;
  final int priceInCents;
  final bool isDeleted;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInCents,
    this.isDeleted = false,
  });

  Item copyWith({
    Identifier<Item>? id,
    String? name,
    String? description,
    int? priceInCents,
    bool? isDeleted,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceInCents: priceInCents ?? this.priceInCents,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "ID: $id\nName: $name\nDescription: $description\nPrice: $priceInCents cents";
  }
}
