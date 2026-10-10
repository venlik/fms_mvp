import 'package:finance_management_system/backend/enums/entity_type.dart';

abstract interface class Entity {}

class Identifier<T extends Entity> {
  final int number;
  final EntityType type;

  const Identifier(this.number, this.type);

  String get value => '${type.label}-${number.toString().padLeft(4, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identifier<T> && other.number == number && other.type == type);

  @override
  int get hashCode => Object.hash(number, type);

  @override
  String toString() => value;
}