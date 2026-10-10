import 'package:finance_management_system/backend/drafts/draft_invoice.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/entity_type.dart';
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

  final Map<int, Invoice> _entries = {};
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
    date: DateTime.now(),
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
    if (await _exists(draft.contentHash!)) {
      throw AlreadyExists(
        "Invoice of C_HASH: ${draft.contentHash} already exists",
      );
    }
    final number = await nextNumber();
    final invoice = draft.toInvoice(number);
    await save(invoice);
    return invoice;
  }

  // ── persistence ─────────────────────────────────────────────────

  Future<void> save(Invoice invoice) async {
    await _ensureLoaded();
    if (_entries.containsKey(invoice.documentNumber.id) ||
        await _exists(invoice.contentHash)) {
      throw AlreadyExists(
        "Invoice of C_HASH: ${invoice.contentHash} already exists",
      );
    }
    _entries[invoice.documentNumber.id] = invoice;
    await _persist();
  }

  Future<void> delete(int number) async {
    await _ensureLoaded();
    if (_entries.remove(number) == null) {
      throw NotFound('Invoice $number not found');
    }
    await _persist();
  }

  // ── lookup ──────────────────────────────────────────────────────

  @override
  Future<Invoice?> findByNumber(int number) async {
    await _ensureLoaded();
    return _entries[number];
  }

  Future<Iterable<Invoice>> findAll() async {
    await _ensureLoaded();
    return _entries.values;
  }

  Future<bool> _exists(int contentHash) async {
    await _ensureLoaded();
    for (final invoice in _entries.values) {
      if (invoice.contentHash == contentHash) {
        return true;
      }
    }
    return false;
  }

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
      for (final json in list.cast<Map<String, dynamic>>()) {
        final inv = await _deserialize(json);
        _entries[inv.documentNumber.id] = inv;
      }
    }
  }

  Future<Invoice> _deserialize(Map<String, dynamic> json) async {
    final businessId = json['businessId'] as int;
    final business = await _businesses.findById(
      Identifier<Business>(businessId, EntityType.business),
    );
    if (business == null) {
      throw NotFound('Business $businessId referenced by invoice not found');
    }

    final customerId = json['customerId'] as int;
    final customer = await _customers.findById(
      Identifier<Customer>(customerId, EntityType.customer),
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
        Identifier<Item>(itemId, EntityType.item),
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
      paymentTerms: terms,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> _serialize(Invoice i) => i.toMap();

  Future<void> _persist() async {
    await _storage.writeData(_group, {
      'invoices': _entries.values.map(_serialize).toList(),
    });
  }
}
