import 'dart:typed_data';

import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

/// Adds logo-byte resolution to [Business] without polluting the
/// model with I/O concerns.
///
/// The store is passed in because extensions can't hold state, and
/// resolution needs a source. In production, pass [LocalLogoStore].
extension BusinessLogoX on Business {
  /// Resolves [logo] to bytes using [store].
  ///
  /// Returns null if this business has no logo, or if the underlying
  /// source can't be read. Never throws for a missing logo.
  Future<Uint8List?> resolveLogoBytes(LogoStore store) async {
    final l = logo;
    if (l == null) return null;
    return store.bytesOf(l);
  }
}