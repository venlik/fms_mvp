import 'package:finance_management_system/backend/enums/counter_key.dart';
import 'package:finance_management_system/backend/enums/storage_group.dart';
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
  const CounterService(this.storage);

  static const String _key = 'counters';
  static const _group = StorageGroup.counters;

  Future<int> current(CounterKey key) async {
    final counters = await _readAll();
    return counters[key.id] ?? 0;
  }

  /// Atomically bumps [key] and returns the new value.
  /// Assumes single-process access (desktop app). See note below.
  Future<int> allocate(CounterKey key) async {
    final counters = await _readAll();
    final next = (counters[key.id] ?? 0) + 1;
    counters[key.id] = next;
    await _writeAll(counters);
    return next;
  }

  Future<void> reset(CounterKey key, int value) async {
    final counters = await _readAll();
    counters[key.id] = value;
    await _writeAll(counters);
  }

  /// Full snapshot, for diagnostics or migrations.
  Future<Map<CounterKey, int>> snapshot() async {
    final raw = await _readAll();
    return {
      for (final k in CounterKey.values) k: raw[k.id] ?? 0,
    };
  }

  // ── plumbing ─────────────────────────────────────────────────────

  Future<Map<String, int>> _readAll() async {
    
    final data = await storage.readData(_group);
    final raw = data[_key];
    if (raw is! Map) return {};

    final out = <String, int>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is num) out[e.key as String] = v.toInt();
    }
    return out;
  }

  Future<void> _writeAll(Map<String, int> counters) async {
    final data = await storage.readData(_group);
    data[_key] = counters;
    await storage.writeData(_group, data);
  }
}