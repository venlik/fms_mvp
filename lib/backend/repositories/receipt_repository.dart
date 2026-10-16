import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/document_number.dart';
import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/invoice.dart';
import 'package:finance_management_system/backend/models/payment.dart';
import 'package:finance_management_system/backend/models/receipt.dart';
import 'package:finance_management_system/backend/repositories/invoice_lookup.dart';
import 'package:finance_management_system/backend/repositories/payment_lookup.dart';
import 'package:finance_management_system/backend/services/counter_service.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

/// Persists receipts. One receipt per payment; the number is allocated
/// on first request and stays stable thereafter. Loads lazily on first
/// access, same as every other repository.
class ReceiptRepository {
  final Storage _storage;
  final CounterService _counters;
  final InvoiceLookup _invoices;
  final PaymentLookup _payments;

  final Map<DocumentNumber<Receipt>, Receipt> _entries = {};
  bool _loaded = false;

  static const _group = StorageGroup.receipts;

  ReceiptRepository._(
    this._storage,
    this._counters,
    this._invoices,
    this._payments,
  );

  static Future<ReceiptRepository> create({
    required Storage storage,
    required CounterService counters,
    required InvoiceLookup invoices,
    required PaymentLookup payments,
  }) async {
    final repo = ReceiptRepository._(storage, counters, invoices, payments);
    await repo._ensureLoaded();
    return repo;
  }

  // ── identity ─────────────────────────────────────────────────────

  Future<DocumentNumber<Receipt>> _nextNumber() async {
    final n = await _counters.allocate(CounterKey.receipt);
    return DocumentNumber<Receipt>(n);
  }

  // ── draft-free API ───────────────────────────────────────────────

  /// Gets the receipt for [payment], creating one on first request.
  /// Idempotent: calling twice for the same payment returns the same
  /// receipt and does not burn a number.
  Future<Receipt> forPayment({
    required Invoice invoice,
    required Payment payment,
  }) async {
    await _ensureLoaded();

    if (invoice.documentNumber.id != payment.invoiceNumber.id) {
      throw InvalidState(
        'Payment references invoice ${payment.invoiceNumber}, '
        'but was paired with invoice ${invoice.documentNumber}',
      );
    }

    final existing = _findByPayment(payment);
    if (existing != null) return existing;

    final number = await _nextNumber();
    final receipt = Receipt(
      receiptId: number,
      invoice: invoice,
      payment: payment,
    );
    await add(receipt);
    return receipt;
  }

  // ── already-identified ───────────────────────────────────────────

  Future<void> add(Receipt receipt) async {
    await _ensureLoaded();
    if (_entries.containsKey(receipt.receiptId)) {
      throw AlreadyExists('Receipt ${receipt.receiptId} already exists');
    }
    if (_findByPayment(receipt.payment) != null) {
      throw AlreadyExists(
        'A receipt already exists for payment ${receipt.payment.id}',
      );
    }
    final tmp = _snapshot;
    tmp[receipt.receiptId] = receipt;
    await _persistAndLoad(tmp);
  }

  // ── lookup ───────────────────────────────────────────────────────

  Future<Receipt?> findByNumber(DocumentNumber<Receipt> number) async {
    await _ensureLoaded();
    final receipt = _entries[number];
    if (receipt == null) {
      throw NotFound('Receipt $number not found');
    }
    return receipt;
  }

  Future<Receipt?> findByPayment(Payment payment) async {
    await _ensureLoaded();
    return _findByPayment(payment);
  }

  Receipt? _findByPayment(Payment payment) {
    for (final r in _entries.values) {
      if (r.payment.id == payment.id) return r;
    }
    return null;
  }

  Future<Iterable<Receipt>> findAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_entries.values);
  }

  // ── persistence ──────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  Map<DocumentNumber<Receipt>, Receipt> get _snapshot => Map.of(_entries);

  Future<void> _load() async {
    final raw = await _storage.readData(_group);
    final list = raw['receipts'];
    if (list is! List) return;
    _entries.clear();
    for (final json in list.cast<Map<String, dynamic>>()) {
      try {
        final r = await _deserialize(json);
        _entries[r.receiptId] = r;
      } on NotFound catch (_) {
        assert(() {
          // ignore: avoid_print
          print('skipped: referenced payment or invoice not found');
          return true;
        }());
        continue;
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Receipt> _deserialize(Map<String, dynamic> json) async {
    final paymentId = Identifier<Payment>(json['paymentId'] as int);
    final payment = await _payments.findById(paymentId);
    if (payment == null) {
      throw NotFound('Payment $paymentId referenced by receipt not found');
    }

    final invoiceNo = DocumentNumber<Invoice>(json['invoiceNumber'] as int);
    final invoice = await _invoices.findByNumber(
      invoiceNo,
      includeDeleted: true,
    );
    if (invoice == null) {
      throw NotFound('Invoice $invoiceNo referenced by receipt not found');
    }

    return Receipt(
      receiptId: DocumentNumber<Receipt>(json['receiptId'] as int),
      invoice: invoice,
      payment: payment,
    );
  }

  Map<String, dynamic> _serialize(Receipt r) => {
    'receiptId': r.receiptId.id,
    'paymentId': r.payment.id.number,
    'invoiceNumber': r.invoice.documentNumber.id,
  };

  Future<void> _save([Map<DocumentNumber<Receipt>, Receipt>? entries]) async {
    final ent = entries ?? _entries;
    await _storage.writeData(_group, {
      'receipts': ent.values.map(_serialize).toList(),
    });
  }

  Future<void> _persistAndLoad(
    Map<DocumentNumber<Receipt>, Receipt> tmp,
  ) async {
    await _save(tmp);
    await _load();
  }
}