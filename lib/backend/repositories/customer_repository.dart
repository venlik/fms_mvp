// repositories/customer_repository.dart
import 'package:finance_management_system/backend/details/customer_details_comparison.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
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
    if (await _contentExists(draft)) {
      throw AlreadyExists(
        'A customer with the same name and phone already exists',
      );
    }
    final n = await _counters.allocate(CounterKey.customer);
    final customer = Customer(
      id: Identifier<Customer>(n),
      name: draft.name,
      address: draft.address,
      phoneNumber: draft.phoneNumber,
      email: draft.email,
    );
    await add(customer);
    return customer;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(
    Customer customer, [
    Map<Identifier<Customer>, Customer>? snapshot,
  ]) async {
    await _ensureLoaded();
    final ent = snapshot ?? _entries;
    if (ent.containsKey(customer.id) || await _contentExists(customer, ent)) {
      throw AlreadyExists(
        'A customer with the same name and phone already exists',
      );
    }
    final tmp = snapshot ?? _snapshot;
    tmp[customer.id] = customer;
    await _persistAndLoad(tmp);
  }

  Future<void> update(Customer customer) async {
    await _ensureLoaded();
    if (!_entries.containsKey(customer.id)) {
      throw NotFound('Customer ${customer.id} not found');
    }
    final tmp = _snapshot;
    if (tmp.remove(customer.id) != null) {
      await add(customer, tmp);
    }
    //await _persistAndLoad(tmp);
  }

  Future<void> softDelete(Identifier<Customer> id) async {
    await _ensureLoaded();
    final existing = _entries[id];
    if (existing == null) {
      throw NotFound('Customer $id not found');
    }
    final tmp = _snapshot;
    tmp[id] = existing.copyWith(isDeleted: true);
    await _persistAndLoad(tmp);
  }

  // ── lookup ───────────────────────────────────────────────────────

  @override
  Future<Customer?> findById(
    Identifier<Customer> id, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    final customer = _entries[id];

    if (customer == null) return null;

    if (!includeDeleted && customer.isDeleted) {
      throw InvalidState("Cannot find customer: customer is deleted.");
    }

    return customer;
  }

  @override
  Future<Map<Identifier<Customer>, Customer>> findByIds(
    Iterable<Identifier<Customer>> ids, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    return {
      for (final id in ids)
        if (_entries[id] case final c?)
          if (includeDeleted || !c.isDeleted) id: c,
    };
  }

  Future<Iterable<Customer>> findAll({bool includeDeleted = false}) async {
    await _ensureLoaded();

    return List.unmodifiable(
      _entries.values.where((c) => includeDeleted || !c.isDeleted),
    );
  }

  Future<Iterable<Customer>> findByName(
    String name, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    final q = name.toLowerCase();

    return _entries.values.where(
      (c) =>
          (includeDeleted || !c.isDeleted) && c.name.toLowerCase().contains(q),
    );
  }

  Map<Identifier<Customer>, Customer> get _snapshot => Map.of(_entries);

  /// Checks whether any non-deleted entry has the same content
  /// significance as [candidate].
  Future<bool> _contentExists(
    CustomerDetailsComparison candidate, [
    Map<Identifier<Customer>, Customer>? snapshot,
  ]) async {
    await _ensureLoaded();
    final entries = snapshot ?? _entries;
    return entries.values
        .where((c) => !c.isDeleted)
        .any((c) => c.details == candidate.details);
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
    id: Identifier<Customer>(json['id'] as int),
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

  Future<void> _save([Map<Identifier<Customer>, Customer>? entries]) async {
    final ent = entries ?? _entries;
    final raw = await _storage.readData(_group);
    raw['customers'] = ent.values.map(_serialize).toList();
    await _storage.writeData(_group, raw);
  }

  Future<void> _persistAndLoad(Map<Identifier<Customer>, Customer> tmp) async {
    await _save(tmp);
    await _load();
  }
}
