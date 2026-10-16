// lib/frontend/flutter/bootstrap.dart
import 'package:finance_management_system/backend/services/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/platform/document_opener.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_storage.dart';
import 'package:finance_management_system/frontend/flutter/platform/flutter_logo_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

late final Services services;

late final FlutterStorage storage;
late final DocumentOpener documentOpener;

/// Used by non-widget code that needs to push a route — notably the
/// previewer adapter, whose interface has no `BuildContext`.
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  storage = await FlutterStorage.create();
  final logoStore = const FlutterLogoStore();
  documentOpener = DocumentOpener.forPlatform();

  services = await bootStrapServices(storage, logoStore);
}
