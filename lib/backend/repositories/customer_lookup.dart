import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/identifier.dart';

abstract interface class CustomerLookup {
  Future<Customer?> findById(Identifier<Customer> id);
  Future<Map<Identifier<Customer>, Customer>> findByIds(
    Iterable<Identifier<Customer>> ids,
  );
}
