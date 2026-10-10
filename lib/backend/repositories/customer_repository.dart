// repositories/customer_repository.dart
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/entity_type.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/repositories/customer_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

class CustomerRepository implements CustomerLookup {
  final Storage _storage;
  final CounterService _counters;
  final Map<Identifier<Customer>, Customer> _entries = {};
  bool _loaded = false;

  static const _group = StorageGroup.customers;
  CustomerRepository._(this._storage, this._counters);

  static Future<CustomerRepository> create({
    required Storage storage,
    required CounterService counters,
  }) async {
    final repo = CustomerRepository._(storage, counters);
    await repo._load();
    return repo;
  }

  // ── draft → entity ───────────────────────────────────────────────

  DraftCustomer createDraft({
    String name = '',
    String address = '',
    String phoneNumber = '',
    String? email,
  }) => DraftCustomer(
    name: name,
    address: address,
    phoneNumber: phoneNumber,
    email: email,
  );

  Future<Customer> commit(DraftCustomer draft) async {
    if (!draft.isValid) {
      throw InvalidState('Customer draft is incomplete');
    }
    if (await _exists(draft.contentHash)) {
      throw AlreadyExists(
        'Customer of C_HASH ${draft.contentHash} already exists',
      );
    }
    final n = await _counters.allocate(CounterKey.customer);
    final customer = Customer(
      id: Identifier<Customer>(n, EntityType.customer),
      name: draft.name,
      address: draft.address,
      phoneNumber: draft.phoneNumber,
      email: draft.email,
    );
    await add(customer);
    return customer;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(Customer customer) async {
    await _ensureLoaded();
    if (_entries.containsKey(customer.id) |
        await _exists(customer.contentHash)) {
      throw AlreadyExists(
        'Customer of C_HASH ${customer.contentHash} already exists',
      );
    }
    _entries[customer.id] = customer;
    await _save();
  }

  Future<void> update(Customer customer) async {
    await _ensureLoaded();
    if (!_entries.containsKey(customer.id)) {
      throw NotFound('Customer ${customer.id} not found');
    }
    _entries[customer.id] = customer;
    await _save();
  }

  Future<void> softDelete(Identifier<Customer> id) async {
    await _ensureLoaded();
    final existing = _entries[id];
    if (existing == null) {
      throw NotFound('Customer $id not found');
    }
    _entries[id] = existing.copyWith(isDeleted: true);
    await _save();
  }

  // ── lookup ───────────────────────────────────────────────────────

  @override
  Future<Customer?> findById(Identifier<Customer> id) async {
    await _ensureLoaded();
    return _entries[id]; // returns even if soft-deleted
  }

  @override
  Future<Map<Identifier<Customer>, Customer>> findByIds(
    Iterable<Identifier<Customer>> ids,
  ) async {
    await _ensureLoaded();
    return {
      for (final id in ids)
        if (_entries[id] case final c?) id: c,
    };
  }

  Future<Customer?> findByIdActive(Identifier<Customer> id) async {
    final c = await findById(id);
    if (c == null || c.isDeleted) return null;
    return c;
  }

  Future<Iterable<Customer>> findAll() async {
    await _ensureLoaded();
    return _entries.values.where((c) => !c.isDeleted);
  }

  Future<Iterable<Customer>> findByName(String name) async {
    await _ensureLoaded();
    final q = name.toLowerCase();
    return _entries.values.where(
      (c) => !c.isDeleted && c.name.toLowerCase().contains(q),
    );
  }

  Future<bool> _exists(int contentHash) async {
    await _ensureLoaded();
    for (final customer in _entries.values) {
      if (customer.contentHash == contentHash) {
        return true;
      }
    }
    return false;
  }

  // ── persistence ──────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  Future<void> _load() async {
    final raw = await _storage.readData(_group);
    final list = raw['customers'];
    if (list is! List) return;
    _entries
      ..clear()
      ..addEntries(
        list.cast<Map<String, dynamic>>().map((json) {
          final c = _deserialize(json);
          return MapEntry(c.id, c);
        }),
      );
  }

  Customer _deserialize(Map<String, dynamic> json) => Customer(
    id: Identifier<Customer>(json['id'] as int, EntityType.customer),
    name: json['name'] as String,
    address: json['address'] as String,
    phoneNumber: json['phoneNumber'] as String,
    email: json['email'] as String?,
    isDeleted: json['isDeleted'] as bool? ?? false,
  );

  Map<String, dynamic> _serialize(Customer c) => {
    'id': c.id.number,
    'name': c.name,
    'address': c.address,
    'phoneNumber': c.phoneNumber,
    'email': c.email,
    'isDeleted': c.isDeleted,
  };

  Future<void> _save() async {
    final raw = await _storage.readData(_group);
    raw['customers'] = _entries.values.map(_serialize).toList();
    await _storage.writeData(_group, raw);
  }
}
