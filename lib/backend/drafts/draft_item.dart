/// A line item being edited. No itemId — the service assigns it at commit.
class DraftItem {
  /// UI-only identity. Never persisted, never reaches the entity layer.
  final Object uiKey = Object();

  String name;
  String description;
  int priceInCents;

  DraftItem({this.name = '', this.description = '', this.priceInCents = 0});

  /// A draft item is usable once it has a name and a positive quantity.
  bool get isValid =>
      name.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      priceInCents > 0;

  DraftItem copyWith({String? name, String? description, int? priceInCents}) {
    return DraftItem(
      name: name ?? this.name,
      description: description ?? this.description,
      priceInCents: priceInCents ?? this.priceInCents,
    );
  }

  int get contentHash => name.hashCode ^ description.hashCode << 10;
}
