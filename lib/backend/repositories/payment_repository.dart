import 'package:finance_management_system/backend/details/payment_details_comparison.dart';
import 'package:finance_management_system/backend/enums/counter_key.dart';
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
    String? reference,
    String? notes,
    DateTime? date,
  }) => DraftPayment(
    invoiceNumber: invoiceNumber,
    method: method,
    amountInCents: amountInCents,
    reference: reference,
    notes: notes,
    date: date ?? DateTime.timestamp(),
  );

  Future<Payment> commit(DraftPayment draft, int invoiceBalance) async {
    if (!draft.isValid) {
      throw InvalidState('Payment draft is incomplete');
    }
    if (await _contentExists(draft)) {
      throw AlreadyExists(
        "Payment with details (${draft.details}) already exists",
      );
    }
    // Cross-repo validation: the invoice must exist.
    final invoice = await _invoices.findByNumber(draft.invoiceNumber);
    if (invoice == null) {
      throw NotFound('Invoice ${draft.invoiceNumber.id} not found');
    }
    if (draft.amountInCents > invoiceBalance) {
      throw InvalidState("Payment amount exceeds Invoice balance");
    }
    final n = await _counters.allocate(CounterKey.payment);
    final payment = Payment(
      id: Identifier<Payment>(n),
      amountInCents: draft.amountInCents,
      method: draft.method,
      invoiceNumber: draft.invoiceNumber,
      date: draft.date,
      reference: draft.reference,
      notes: draft.notes,
    );
    await add(payment);
    return payment;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(Payment payment) async {
    await _ensureLoaded();
    if (_entries.containsKey(payment.id) || await _contentExists(payment)) {
      throw AlreadyExists(
        'Payment with details (${payment.details}) already exists',
      );
    }
    final tmp = _snapshot;
    tmp[payment.id] = payment;
    await _persistAndLoad(tmp);
  }

  // ── lookup ───────────────────────────────────────────────────────

  @override
  Future<Payment?> findById(
    Identifier<Payment> id, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();

    final payment = _entries[id];

    if (payment == null) return null;

    if (!includeDeleted && payment.isDeleted) {
      throw InvalidState("payment is deleted");
    }

    return payment;
  }

  @override
  Future<Iterable<Payment>> findByInvoice(
    DocumentNumber<Invoice> invoiceNumber, {
    bool includeDeleted = false,
  }) async {
    await _ensureLoaded();
    return _entries.values.where(
      (p) =>
          (includeDeleted || !p.isDeleted) && p.invoiceNumber == invoiceNumber,
    );
  }

  Future<Iterable<Payment>> findAll({bool includeDeleted = false}) async {
    await _ensureLoaded();
    return _entries.values.where((p) => includeDeleted || !p.isDeleted);
  }

  Future<bool> _contentExists(PaymentDetailsComparison candidate) async {
    await _ensureLoaded();

    return _entries.values
        .where((p) => !p.isDeleted)
        .any((p) => p.details == candidate.details);
  }

  Map<Identifier<Payment>, Payment> get _snapshot => Map.of(_entries);
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
    _entries.clear();
    for (final json in list.cast<Map<String, dynamic>>()) {
      try {
        final p = await _deserialize(json);
        _entries[p.id] = p;
      } on NotFound catch (_) {
        assert(() {
          // ignore: avoid_print
          print("skipped: invoice not found"); //TODO: return result instead
          return true;
        }());
        continue;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<Payment> _deserialize(Map<String, dynamic> json) async {
    final invNo = DocumentNumber<Invoice>(json['invoiceNumber'] as int);
    final inv = await _invoices.findByNumber(invNo, includeDeleted: true);
    if (inv == null) {
      throw NotFound("invoice of id ${invNo.id} not found");
    }
    return Payment(
      id: Identifier<Payment>(json['id'] as int),
      amountInCents: json['amountInCents'] as int,
      method: PaymentMethod.values.byName(json['method'] as String),
      invoiceNumber: invNo,
      date: DateTime.parse(json['date'] as String),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _serialize(Payment p) => {
    'id': p.id.number,
    'amountInCents': p.amountInCents,
    'method': p.method.name,
    'invoiceNumber': p.invoiceNumber.id,
    'date': p.date.toIso8601String(),
    'reference': p.reference,
    'notes': p.notes,
    'isDeleted': p.isDeleted,
  };

  Future<void> _save([Map<Identifier<Payment>, Payment>? entries]) async {
    final raw = await _storage.readData(_group);
    final ent = entries ?? _entries;
    raw['payments'] = ent.values.map(_serialize).toList();
    await _storage.writeData(_group, raw);
  }

  Future<void> _persistAndLoad(Map<Identifier<Payment>, Payment> tmp) async {
    await _save(tmp);
    await _load();
  }
}
