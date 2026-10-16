import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/storage/app_storage.dart';

/// Single source of truth for all monotonic integer sequences.
///
/// A counter is a named bucket in counters.json, keyed by
/// [CounterKey.id]:
///
/// {
///   "invoice":  3,
///   "receipt":  1,
///   "item":     5
/// }
///
/// The service is deliberately dumb: read/write ints by key. It knows
/// nothing about invoices, items, or any domain concept.
class CounterService {
  final Storage storage;
  CounterService(this.storage);

  static const String _key = 'counters';
  static const _group = StorageGroup.counters;

  bool _allocating = false;

  Future<int> current(CounterKey key) async {
    final counters = await _readAll();
    return counters[key.id] ?? 0;
  }

  /// Atomically bumps [key] and returns the new value.
  ///
  /// Safety relies on the caller-side invariant that no two [allocate]
  /// calls are ever in flight concurrently. The read-modify-write below
  /// has two `await` points (`_readAll`, `_writeAll`) between which
  /// another `allocate` could interleave and lose an increment. Today
  /// every caller is sequential (commit paths are awaited serially),
  /// so this holds. If that ever changes — batch commits, parallel
  /// UI actions, a future scheduler — wrap this method in a mutex or
  /// move counters into memory.
  Future<int> allocate(CounterKey key) async {
    assert(!_allocating, 'CounterService.allocate called concurrently');
    _allocating = true;
    try {
      final counters = await _readAll();
      final next = (counters[key.id] ?? 0) + 1;
      counters[key.id] = next;
      await _writeAll(counters);
      return next;
    } finally {
      _allocating = false;
    }
  }

  ///deffered API
  // Future<void> reset(CounterKey key, int value) async {
  //   if (value < 0) {
  //     throw StateError("value can`t be negative");
  //   }
  //   final counters = await _readAll();
  //   counters[key.id] = value;
  //   await _writeAll(counters);
  // }

  /// Full snapshot, for diagnostics or migrations.
  Future<Map<CounterKey, int>> snapshot() async {
    final raw = await _readAll();
    return {for (final k in CounterKey.values) k: raw[k.id] ?? 0};
  }

  // ── plumbing ─────────────────────────────────────────────────────

  Future<Map<String, int>> _readAll() async {
    final data = await storage.readData(_group);
    final raw = data[_key];
    if (raw is! Map) return {};

    final out = <String, int>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is num) {
        out[e.key as String] = v.toInt();
      } else {
        throw StorageFailure(
          "Expected num counters but encounted Non-number ($v - type=${v.runtimeType})",
        );
      }
    }
    return out;
  }

  Future<void> _writeAll(Map<String, int> counters) async {
    final data = await storage.readData(_group);
    data[_key] = counters;
    await storage.writeData(_group, data);
  }
}
