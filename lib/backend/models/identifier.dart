import 'package:finance_management_system/backend/enums/entity_type.dart';
import 'package:finance_management_system/backend/exceptions.dart';
import 'package:finance_management_system/backend/models/business.dart';
import 'package:finance_management_system/backend/models/customer.dart';
import 'package:finance_management_system/backend/models/item.dart';
import 'package:finance_management_system/backend/models/payment.dart';

abstract interface class Entity {}

class Identifier<T extends Entity> {
  final int number;
  Type get t => T;

  const Identifier(this.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identifier<T> && other.number == number);

  @override
  int get hashCode => Object.hash(number, t);

  @override
  String toString() => '$t#$number';
}

/// Maps each entity class to its [EntityType]. Every new entity must
/// add an entry here, or any `.value` access on its [Identifier]
/// throws at runtime
const _entityTypes = <Type, EntityType>{
  Customer: EntityType.customer,
  Business: EntityType.business,
  Item: EntityType.item,
  Payment: EntityType.payment,
};

extension IdentifierExtras on Identifier {
  EntityType get type {
    final et = _entityTypes[t];
    if (et == null) {
      throw NotFound('EntityType of type $t not found');
    }
    return et;
  }

  String get value => '${type.label}-${number.toString().padLeft(4, '0')}';
}
