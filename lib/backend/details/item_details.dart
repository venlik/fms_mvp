import 'package:finance_management_system/backend/details/equatable.dart';

/// The fields that determine when two catalog entries are the same
/// product or service.
///
/// Included:
///   • [name]        — what it is
///   • [description] — how it's distinguished from similarly-named items
///
/// Intentionally excluded:
///   • priceInCents — mutable; editing a price doesn't create a new item
///   • isDeleted    — lifecycle flag, not content
class ItemDetails with Equatable {
  final String name;
  final String description;

  const ItemDetails({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];

  @override
  String toString() => 'ItemDetails(name: $name, desc: $description)';
}