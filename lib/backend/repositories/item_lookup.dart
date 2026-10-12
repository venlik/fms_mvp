import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/item.dart';

abstract interface class ItemLookup {
  Future<Item?> findById(Identifier<Item> id, {bool includeDeleted = false});
}
