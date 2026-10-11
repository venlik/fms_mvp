import 'package:finance_management_system/backend/details/item_details_comparison.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/backend/repositories/item_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

class ItemRepository implements ItemLookup {
  final Storage _storage;
  final CounterService _counterService;

  static const _group = StorageGroup.items;
  final Map<Identifier<Item>, Item> _entries = {};
  bool _loaded = false;

  ItemRepository._(this._storage, this._counterService);

  static Future<ItemRepository> create({
    required Storage storage,
    required CounterService counters,
  }) async {
    final repo = ItemRepository._(storage, counters);
    await repo._ensureLoaded();
    return repo;
  }

  // ── identity ────────────────────────────────────────────────────

  Future<Identifier<Item>> _nextId() async {
    final n = await _counterService.allocate(CounterKey.item);
    return Identifier<Item>(n);
  }

  // ── draft → entity ──────────────────────────────────────────────

  DraftItem createDraft({
    String name = '',
    String description = '',
    int priceInCents = 0,
  }) => DraftItem(
    name: name,
    description: description,
    priceInCents: priceInCents,
  );

  Future<Item> commit(DraftItem draft) async {
    if (!draft.isValid) {
      throw InvalidState('Item draft is incomplete');
    }

    if (await _contentExists(draft)) {
      throw AlreadyExists(
        'Item with details (${draft.details}) already exists',
      );
    }
    final id = await _nextId();
    final item = Item(
      id: id,
      name: draft.name,
      description: draft.description,
      priceInCents: draft.priceInCents,
    );
    await add(item);
    return item;
  }

  Future<void> commitAll(List<DraftItem> drafts) async {
    for (final draft in drafts) {
      try {
        await commit(draft);
      } on AlreadyExists catch (_) {
        print(
          "skipped: [${draft.details}] reason: [exists]",
        ); //TODO: remove print statement
        continue;
      } catch (_) {
        rethrow;
      }
    }
  }

  // ── already-identified ──────────────────────────────────────────

  Future<void> add(Item item) async {
    await _ensureLoaded();
    if (_entries.containsKey(item.id) || await _contentExists(item)) {
      throw AlreadyExists(
        'Item with details (${item.details}) already exists',
      );
    }
    _entries[item.id] = item;
    await _save();
  }

  Future<void> remove(Item item) async {
    await _ensureLoaded();
    if (!_entries.containsKey(item.id)) {
      throw NotFound('Item ${item.id} not found');
    }
    _entries[item.id] = item.copyWith(isDeleted: true);
    await _save();
  }

  // ── lookup ──────────────────────────────────────────────────────

  @override
  Future<Item?> findById(Identifier<Item> id) async {
    await _ensureLoaded();
    return _entries[id];
  }

  Future<Iterable<Item>> findByName(String name) async {
    await _ensureLoaded();
    final q = name.toLowerCase();
    return _entries.values.where((it) => it.name.toLowerCase() == q);
  }

  Future<Iterable<Item>> findAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_entries.values);
  }

  Future<bool> _contentExists(ItemDetailsComparison candidate) async {
    await _ensureLoaded();
    return _entries.values
        .where((it) => !it.isDeleted)
        .any((it) => it.details == candidate.details);
  }

  // ── internals ───────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final raw = await _storage.readData(_group);
    final list = raw['items'];
    if (list is List) {
      _entries
        ..clear()
        ..addEntries(
          list.cast<Map<String, dynamic>>().map((json) {
            final it = _deserialize(json);
            return MapEntry(it.id, it);
          }),
        );
    }
    _loaded = true;
  }

  Item _deserialize(Map<String, dynamic> json) => Item(
    id: Identifier<Item>(json['id'] as int),
    name: json['name'] as String,
    description: json['description'] as String,
    priceInCents: json['priceInCents'] as int,
    isDeleted: json['isDeleted'] as bool? ?? false,
  );

  Map<String, dynamic> _serialize(Item it) => {
    'id': it.id.number,
    'name': it.name,
    'description': it.description,
    'priceInCents': it.priceInCents,
    'isDeleted': it.isDeleted,
  };

  Future<void> _save() async {
    await _storage.writeData(_group, {
      'items': _entries.values.map(_serialize).toList(),
    });
  }
}
