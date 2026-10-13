import 'package:finance_management_system/backend/details/invoice_details_comparison.dart';
import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/payment_terms.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/invoice_item.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/backend/repositories/business_lookup.dart';
import 'package:finance_management_system/backend/repositories/customer_lookup.dart';
import 'package:finance_management_system/backend/repositories/invoice_lookup.dart';
import 'package:finance_management_system/backend/repositories/item_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

class InvoiceRepository implements InvoiceLookup {
  final Storage _storage;
  final CounterService _counterService;
  final BusinessLookup _businesses;
  final CustomerLookup _customers;
  final ItemLookup _items;

  final Map<DocumentNumber<Invoice>, Invoice> _entries = {};
  bool _loaded = false;

  static const _group = StorageGroup.invoices;

  InvoiceRepository._(
    this._storage,
    this._counterService,
    this._businesses,
    this._customers,
    this._items,
  );

  static Future<InvoiceRepository> create({
    required Storage storage,
    required CounterService counters,
    required BusinessLookup businesses,
    required CustomerLookup customers,
    required ItemLookup items,
  }) async {
    final repo = InvoiceRepository._(
      storage,
      counters,
      businesses,
      customers,
      items,
    );
    await repo._ensureLoaded();
    return repo;
  }

  // ── identity ────────────────────────────────────────────────────

  Future<DocumentNumber<Invoice>> nextNumber() async {
    final n = await _counterService.allocate(CounterKey.invoice);
    return DocumentNumber(n);
  }

  // ── draft → entity ──────────────────────────────────────────────

  DraftInvoice createDraftInvoice({
    required Business business,
    required Customer customer,
    required Set<InvoiceItem> items,
    required PaymentTerms paymentTerms,
    String? notes,
  }) => DraftInvoice(
    date: DateTime.timestamp(),
    business: business,
    customer: customer,
    items: items,
    terms: paymentTerms,
    notes: notes,
  );

  Future<Invoice> commit(DraftInvoice draft) async {
    if (!draft.canIssue) {
      throw InvalidState('Draft is not complete');
    }
    if (await _contentExists(draft)) {
      throw AlreadyExists(
        "Invoice with details (${draft.details}) already exists",
      );
    }
    final number = await nextNumber();
    final invoice = draft.toInvoice(number);
    await add(invoice);
    return invoice;
  }

  // ── persistence ─────────────────────────────────────────────────

  Future<void> add(Invoice invoice) async {
    await _ensureLoaded();
    if (_entries.containsKey(invoice.documentNumber) ||
        await _contentExists(invoice)) {
      throw AlreadyExists(
        "Invoice with details (${invoice.details}) already exists",
      );
    }
    final tmp = _snapshot;
    tmp[invoice.documentNumber] = invoice;
    await _persistAndLoad(tmp);
  }

  Future<void> delete(DocumentNumber<Invoice> number) async {
    await _ensureLoaded();
    final tmp = _snapshot;
    final existing = tmp[number];
    if (existing != null) {
      tmp[number] = existing.copyWith(isDeleted: true);
    } else {
      throw NotFound('Invoice $number not found');
    }
    await _persistAndLoad(tmp);
  }

  // ── lookup ──────────────────────────────────────────────────────

  @override
  Future<Invoice?> findByNumber(
    DocumentNumber<Invoice> number, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    final invoice = _entries[number];

    if (invoice == null) return null;

    if (!includeDeleted && invoice.isDeleted) {
      throw InvalidState("Cannot find invoice: invoice is deleted.");
    }

    return invoice;
  }

  Future<Iterable<Invoice>> findAll({bool includeDeleted = false}) async {
    await _ensureLoaded();

    return List.unmodifiable(
      _entries.values.where((invoice) => includeDeleted || !invoice.isDeleted),
    );
  }

  Future<bool> _contentExists(InvoiceDetailsComparison candidate) async {
    await _ensureLoaded();
    return _entries.values
        .where((i) => !i.isDeleted)
        .any((i) => i.details == candidate.details);
  }

  Map<DocumentNumber<Invoice>, Invoice> get _snapshot => Map.of(_entries);

  // ── internals ───────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  Future<void> _load() async {
    final raw = await _storage.readData(_group);
    final list = raw['invoices'];

    if (list is List) {
      _entries.clear();
      for (final json in list.cast<Map<String, dynamic>>()) {
        final inv = await _deserialize(json);
        _entries[inv.documentNumber] = inv;
      }
    }
  }

  Future<Invoice> _deserialize(Map<String, dynamic> json) async {
    final businessId = json['businessId'] as int;
    final business = await _businesses.findById(
      Identifier<Business>(businessId),
      includeDeleted: true,
    );

    if (business == null) {
      throw NotFound('Business $businessId referenced by invoice not found');
    }

    final customerId = json['customerId'] as int;
    final customer = await _customers.findById(
      Identifier<Customer>(customerId),
      includeDeleted: true,
    );
    if (customer == null) {
      throw NotFound('Customer $customerId referenced by invoice not found');
    }

    final itemsJson = (json['items'] as List).cast<Map<String, dynamic>>();
    final items = <InvoiceItem>{};
    for (final entry in itemsJson) {
      final itemId = entry['itemId'] as int;
      final quantity = entry['quantity'] as int;
      final item = await _items.findById(
        Identifier<Item>(itemId),
        includeDeleted: true,
      );
      if (item == null) {
        throw NotFound('Item $itemId referenced by invoice not found');
      }
      items.add(InvoiceItem(item: item, quantity: quantity));
    }

    final terms = PaymentTerms.fromLabel(json['paymentTerms'] as String);
    if (terms == null) {
      throw InvalidState('Unknown payment terms: ${json['paymentTerms']}');
    }

    return Invoice(
      documentNumber: DocumentNumber(json['documentNumber'] as int),
      date: DateTime.parse(json['date'] as String),
      business: business,
      customer: customer,
      items: items,
      terms: terms,
      notes: json['notes'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _serialize(Invoice i) => {
    'documentNumber': i.documentNumber.id,
    'date': i.date.toIso8601String(),
    'businessId': i.business.id.number,
    'customerId': i.customer.id.number,
    'items': i.items
        .map((it) => {'itemId': it.item.id.number, 'quantity': it.quantity})
        .toList(),
    'paymentTerms': i.terms.label,
    'notes': i.notes,
    'isDeleted': i.isDeleted,
  };

  Future<void> _save([Map<DocumentNumber<Invoice>, Invoice>? entries]) async {
    final ent = entries ?? _entries;
    await _storage.writeData(_group, {
      'invoices': ent.values.map(_serialize).toList(),
    });
  }

  Future<void> _persistAndLoad(
    Map<DocumentNumber<Invoice>, Invoice> tmp,
  ) async {
    await _save(tmp);
    await _load();
  }
}
