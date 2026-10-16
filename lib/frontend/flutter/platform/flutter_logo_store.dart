import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/logo.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';
import 'package:meta/meta.dart';

/// Resolves logos from the Flutter asset bundle or the local file
/// system. This is the production implementation.
class FlutterLogoStore implements LogoStore {
  const FlutterLogoStore();

  /// Bytes for each logo already resolved this session. Cached for the
  /// process lifetime — a logo file changing on disk mid-session will
  /// not be picked up. The model forbids editing logos, so this is
  /// consistent with the app's behavior.
  static final Map<Logo, Uint8List?> _cache = {};

  @visibleForTesting
  static void clearCache() => _cache.clear();

  @override
  Future<Uint8List?> bytesOf(Logo logo) async {
    if (_cache.containsKey(logo)) return _cache[logo];
    final bytes = await _load(logo);
    _cache[logo] = bytes;
    return bytes;
  }

  Future<Uint8List?> _load(Logo logo) async {
    try {
      switch (logo.source) {
        case Source.asset:
          final data = await rootBundle.load(logo.path);
          return data.buffer.asUint8List();

        case Source.file:
          final f = File(logo.path);
          if (!await f.exists()) return null;
          return await f.readAsBytes();
      }
    } catch (_) {
      return null;
    }
  }
}
