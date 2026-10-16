import 'package:finance_management_system/backend/details/business_details_comparison.dart';
import 'package:finance_management_system/backend/drafts/draft_business.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/logo.dart';
import 'package:finance_management_system/backend/repositories/business_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

/// Persists the app's business profile(s). Typically a singleton,
/// but modelled as a collection so multiple businesses are possible.
class BusinessRepository implements BusinessLookup {
  final Storage _storage;
  final CounterService _counters;
  final Map<Identifier<Business>, Business> _entries = {};
  bool _loaded = false;

  static const _group = StorageGroup.businesses;

  BusinessRepository._(this._storage, this._counters);

  static Future<BusinessRepository> create({
    required Storage storage,
    required CounterService counters,
  }) async {
    final repo = BusinessRepository._(storage, counters);
    await repo._load();
    return repo;
  }

  // ── draft → entity ───────────────────────────────────────────────

  DraftBusiness createDraft({
    String name = '',
    Logo? logo,
    String phoneNumber = '',
    String email = '',
    String serviceLocation = '',
    String configuredCurrency = 'KES',
  }) => DraftBusiness(
    name: name,
    logo: logo,
    phoneNumber: phoneNumber,
    email: email,
    serviceLocation: serviceLocation,
    configuredCurrency: configuredCurrency,
  );

  Future<Business> commit(DraftBusiness draft) async {
    if (!draft.isValid) {
      throw InvalidState('Business draft is incomplete');
    }
    if (await _contentExists(draft)) {
      throw AlreadyExists(
        'Business with details (${draft.details}) already exists',
      );
    }
    final n = await _counters.allocate(CounterKey.business);
    final business = Business(
      id: Identifier<Business>(n),
      name: draft.name,
      logo: draft.logo,
      phoneNumber: draft.phoneNumber,
      email: draft.email,
      serviceLocation: draft.serviceLocation,
      configuredCurrency: draft.configuredCurrency,
    );
    await add(business);
    return business;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(
    Business business, [
    Map<Identifier<Business>, Business>? snapshot,
  ]) async {
    await _ensureLoaded();
    final ent = snapshot ?? _entries;
    if (await _contentExists(business, ent) || ent[business.id] != null) {
      throw AlreadyExists(
        'Business with details (${business.details}) already exists',
      );
    }
    final tmp = snapshot ?? _snapshot;
    tmp[business.id] = business;
    await _persistAndLoad(tmp);
  }

  // ── lookup ───────────────────────────────────────────────────────

  @override
  Future<Business?> findById(
    Identifier<Business> id, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    final business = _entries[id];

    if (business == null) return null;

    if (!includeDeleted && business.isDeleted) {
      throw InvalidState("Cannot find business: business is deleted.");
    }

    return business;
  }

  @override
  Future<Map<Identifier<Business>, Business>> findByIds(
    Iterable<Identifier<Business>> ids, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    return {
      for (final id in ids)
        if (_entries[id] case final b?)
          if (includeDeleted || !b.isDeleted) id: b,
    };
  }

  Future<Business> findSingleton({bool includeDeleted = false}) async {
    await _ensureLoaded();

    return _entries.values.firstWhere(
      (business) => includeDeleted || !business.isDeleted,
      orElse: () => throw NotFound("No business found"),
    );
  }

  // ── mutations ──────────────────────────────────────────────────
  Future<void> remove(Business business) async {
    await _ensureLoaded();
    final id = business.id;
    final tmp = _snapshot;
    final existing = tmp[id];

    if (existing != null) {
      tmp[id] = existing.copyWith(isDeleted: true);
    } else {
      throw NotFound("Business[${business.id}] not found");
    }

    await _persistAndLoad(tmp);
  }

  ///Replaces an existing business with the newBusiness,
  ///throws [NotFound] if a business with the same id doesn`t exist,
  ///throws [InvalidState] if the operation fails,
  Future<void> update(Business newBusiness) async {
    await _ensureLoaded();
    final id = newBusiness.id;
    if (_entries[id] == null) {
      throw NotFound("Business $id not found");
    }
    final tmp = _snapshot;
    if (tmp.remove(id) != null) {
      await add(newBusiness, tmp);
    } else {
      throw InvalidState("Business Edit failed");
    }
    // await _persistAndLoad(tmp);
  }

  Map<Identifier<Business>, Business> get _snapshot => Map.of(_entries);

  // ── persistence ──────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  Future<void> _load() async {
    final raw = await _storage.readData(_group);
    final list = raw['businesses'];
    if (list is! List) return;
    _entries
      ..clear()
      ..addEntries(
        list.cast<Map<String, dynamic>>().map((json) {
          final b = _deserialize(json);
          return MapEntry(b.id, b);
        }),
      );
  }

  // BusinessRepository
  Future<bool> _contentExists(
    BusinessDetailsComparison candidate, [
    Map<Identifier<Business>, Business>? snapshot,
  ]) async {
    await _ensureLoaded();
    final entries = snapshot ?? _entries;
    return entries.values
        .where((b) => !(b.isDeleted))
        .any((b) => b.details == candidate.details);
  }

  Business _deserialize(Map<String, dynamic> json) {
    Logo? logo;
    final logoJson = json['logo'];
    if (logoJson != null) {
      final logoMap = logoJson as Map<String, dynamic>;
      final src = Source.fromLabel(logoMap['source'] as String);
      if (src == null) {
        throw StorageFailure('Unknown logo source: ${logoMap['source']}');
      }
      logo = Logo(path: logoMap['path'] as String, source: src);
    }
    return Business(
      id: Identifier<Business>(json['id'] as int),
      name: json['name'] as String,
      logo: logo,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      serviceLocation: json['serviceLocation'] as String,
      configuredCurrency: json['configuredCurrency'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _serialize(Business b) => {
    'id': b.id.number,
    'name': b.name,
    'logo': b.logo != null
        ? {'path': b.logo!.path, 'source': b.logo!.source.label}
        : null,
    'phoneNumber': b.phoneNumber,
    'email': b.email,
    'serviceLocation': b.serviceLocation,
    'configuredCurrency': b.configuredCurrency,
    'isDeleted': b.isDeleted,
  };

  Future<void> _save([Map<Identifier<Business>, Business>? entries]) async {
    final ent = entries ?? _entries;
    final raw = await _storage.readData(_group);
    raw['businesses'] = ent.values.map(_serialize).toList();
    await _storage.writeData(_group, raw);
  }

  Future<void> _persistAndLoad(Map<Identifier<Business>, Business> tmp) async {
    await _save(tmp);
    await _load();
  }
}
