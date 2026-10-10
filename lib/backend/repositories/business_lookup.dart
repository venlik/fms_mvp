import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/identifier.dart';

abstract interface class BusinessLookup {
  Future<Business?> findById(Identifier<Business> id);
  Future<Map<Identifier<Business>, Business>> findByIds(
    Iterable<Identifier<Business>> ids,
  );
}