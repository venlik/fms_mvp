import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/entity_type.dart';
import 'package:finance_management_system/backend/enums/payment_method.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/drafts/draft_payment.dart';
import 'package:finance_management_system/backend/repositories/invoice_lookup.dart';
import 'package:finance_management_system/backend/repositories/payment_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

class PaymentRepository implements PaymentLookup {
  final Storage _storage;
  final CounterService _counters;
  final InvoiceLookup _invoices;
  final Map<Identifier<Payment>, Payment> _entries = {};
  bool _loaded = false;

  static const _group = StorageGroup.payments;

  PaymentRepository._(this._storage, this._counters, this._invoices);

  static Future<PaymentRepository> create({
    required Storage storage,
    required CounterService counters,
    required InvoiceLookup invoices,
  }) async {
    final repo = PaymentRepository._(storage, counters, invoices);
    await repo._load();
    return repo;
  }

  // ── draft → entity ───────────────────────────────────────────────

  DraftPayment createDraft({
    required DocumentNumber<Invoice> invoiceNumber,
    PaymentMethod method = PaymentMethod.cash,
    int amountInCents = 0,
    required String reference,
    String? notes,
  }) => DraftPayment(
    invoiceNumber: invoiceNumber,
    method: method,
    amountInCents: amountInCents,
    reference: reference,
    notes: notes,
  );

  Future<Payment> commit(DraftPayment draft) async {
    if (!draft.isValid) {
      throw InvalidState('Payment draft is incomplete');
    }
    if (await _exists(draft.contentHash)) {
      throw AlreadyExists(
        "Payment of C_HASH: ${draft.contentHash} already exists",
      );
    }
    // Cross-repo validation: the invoice must exist.
    final invoice = await _invoices.findByNumber(draft.invoiceNumber.id);
    if (invoice == null) {
      throw NotFound('Invoice ${draft.invoiceNumber.id} not found');
    }

    final n = await _counters.allocate(CounterKey.payment);
    final payment = Payment(
      id: Identifier<Payment>(n, EntityType.payment),
      amountInCents: draft.amountInCents,
      method: draft.method,
      invoiceNumber: draft.invoiceNumber,
      date: DateTime.now(),
      reference: draft.reference,
      notes: draft.notes,
    );
    await add(payment);
    return payment;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(Payment payment) async {
    await _ensureLoaded();
    if (_entries.containsKey(payment.id) ||
        await _exists(payment.contentHash)) {
      throw AlreadyExists(
        'Payment of C_HASH: ${payment.contentHash} already exists',
      );
    }
    _entries[payment.id] = payment;
    await _save();
  }

  // ── lookup ───────────────────────────────────────────────────────

  @override
  Future<Payment?> findById(Identifier<Payment> id) async {
    await _ensureLoaded();
    return _entries[id];
  }

  @override
  Future<Iterable<Payment>> findByInvoice(int invoiceNumber) async {
    await _ensureLoaded();
    return _entries.values.where((p) => p.invoiceNumber.id == invoiceNumber);
  }

  Future<Iterable<Payment>> findAll() async {
    await _ensureLoaded();
    return _entries.values;
  }

  Future<bool> _exists(int contentHash) async {
    await _ensureLoaded();
    for (final payment in _entries.values) {
      if (payment.contentHash == contentHash) {
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
    final list = raw['payments'];
    if (list is! List) return;
    _entries
      ..clear()
      ..addEntries(
        list.cast<Map<String, dynamic>>().map((json) {
          final p = _deserialize(json);
          return MapEntry(p.id, p);
        }),
      );
  }

  Payment _deserialize(Map<String, dynamic> json) => Payment(
    id: Identifier<Payment>(json['id'] as int, EntityType.payment),
    amountInCents: json['amountInCents'] as int,
    method: PaymentMethod.values.byName(json['method'] as String),
    invoiceNumber: DocumentNumber(json['invoiceNumber'] as int),
    date: DateTime.parse(json['date'] as String),
    reference: json['reference'] as String,
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> _serialize(Payment p) => {
    'id': p.id.number,
    'amountInCents': p.amountInCents,
    'method': p.method.name,
    'invoiceNumber': p.invoiceNumber.id,
    'date': p.date.toIso8601String(),
    'reference': p.reference,
    'notes': p.notes,
  };

  Future<void> _save() async {
    final raw = await _storage.readData(_group);
    raw['payments'] = _entries.values.map(_serialize).toList();
    await _storage.writeData(_group, raw);
  }
}
