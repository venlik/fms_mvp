import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/backend/repositories/item_repository.dart';

class ItemService {
  final ItemRepository _items;

  ItemService._(this._items);

  factory ItemService.of(ItemRepository items) => ItemService._(items);

  // ── draft → entity ──────────────────────────────────────────────

  DraftItem createDraft({
    String name = '',
    String description = '',
    int priceInCents = 0,
  }) => _items.createDraft(
    name: name,
    description: description,
    priceInCents: priceInCents,
  );

  Future<Item> commit(DraftItem draft) => _items.commit(draft);

  // ── queries ─────────────────────────────────────────────────────

  Future<Set<Item>> get items async => Set.unmodifiable(await _items.findAll());

  Future<Item?> byId(Identifier<Item> id) async => await _items.findById(id);

  Future<Iterable<Item>> byName(String name) async =>
      await _items.findByName(name);

  Future<Iterable<Item>> findAll() async => await _items.findAll();

  // ── mutations ───────────────────────────────────────────────────
  Future<void> add(Item item) => _items.add(item);
  Future<void> remove(Item item) => _items.remove(item);
}
