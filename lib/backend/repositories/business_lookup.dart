import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/identifier.dart';

abstract interface class BusinessLookup {
  Future<Business?> findById(
    Identifier<Business> id, {
    bool includeDeleted = false,
  });
  Future<Map<Identifier<Business>, Business>> findByIds(
    Iterable<Identifier<Business>> ids, {
    bool includeDeleted = false,
  });
}
