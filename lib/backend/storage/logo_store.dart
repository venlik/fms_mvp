import 'dart:typed_data';

import 'package:finance_management_system/backend/models/logo.dart';

/// Resolves a [Logo] reference to bytes. Implementations decide where
/// the bytes actually come from (asset bundle, file system, network).
///
/// Returns null if the logo cannot be resolved — a missing file, an
/// unreadable asset, a corrupt source. Never throws for "not found";
/// throws only for genuinely unexpected failures.
abstract interface class LogoStore {
  Future<Uint8List?> bytesOf(Logo logo);
}