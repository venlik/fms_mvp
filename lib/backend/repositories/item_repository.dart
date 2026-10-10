import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/entity_type.dart';
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
  final Set<Item> _entries = {};
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
    return Identifier<Item>(n, EntityType.item);
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

    if (await _exists(draft.contentHash)) {
      throw AlreadyExists(
        'Item of C_HASH: ${draft.contentHash} already exists',
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

  // ── already-identified ──────────────────────────────────────────

  Future<void> add(Item item) async {
    await _ensureLoaded();
    if (_entries.contains(item) || await _exists(item.contentHash)) {
      throw AlreadyExists('Item of C_HASH: ${item.contentHash} already exists');
    }
    _entries.add(item);
    await _save();
  }

  Future<void> remove(Item item) async {
    await _ensureLoaded();
    if (!_entries.contains(item)) {
      throw NotFound('Item ${item.id} not found');
    }
    _entries
      ..remove(item)
      ..add(item.copyWith(isDeleted: true));
    await _save();
  }

  // ── lookup ──────────────────────────────────────────────────────

  @override
  Future<Item?> findById(Identifier<Item> id) async {
    await _ensureLoaded();
    try {
      return _entries.firstWhere((it) => it.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Iterable<Item>> findByName(String name) async {
    await _ensureLoaded();
    final q = name.toLowerCase();
    try {
      return _entries.where((it) => it.name.toLowerCase() == q);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Iterable<Item>> findAll() async {
    await _ensureLoaded();
    return Set.unmodifiable(_entries);
  }

  Future<bool> _exists(int contentHash) async {
    await _ensureLoaded();
    for (final item in _entries) {
      if (item.contentHash == contentHash) {
        return true;
      }
    }
    return false;
  }

  // ── internals ───────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final raw = await _storage.readData(_group);
    final list = raw['items'];
    if (list is List) {
      _entries
        ..clear()
        ..addAll(list.cast<Map<String, dynamic>>().map(_deserialize));
    }
    _loaded = true;
  }

  Item _deserialize(Map<String, dynamic> json) => Item(
    id: Identifier<Item>(json['id'] as int, EntityType.item),
    name: json['name'] as String,
    description: json['description'] as String,
    priceInCents: json['priceInCents'] as int,
    isDeleted: json['isDeleted'] as bool?,
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
      'items': _entries.map(_serialize).toList(),
    });
  }
}
