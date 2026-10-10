// storage/local_logo_store.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/logo.dart';
import 'package:finance_management_system/backend/storage/logo_store.dart';

/// Resolves logos from the Flutter asset bundle or the local file
/// system. This is the production implementation.
class LocalLogoStore implements LogoStore {
  const LocalLogoStore();

  @override
  Future<Uint8List?> bytesOf(Logo logo) async {
    try {
      switch (logo.source) {
        case Source.asset:
          throw Exception("assets are not supported in cli");
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
