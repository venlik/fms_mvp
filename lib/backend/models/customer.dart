import 'package:finance_management_system/backend/models/identifier.dart';

class Customer implements Entity {
  final Identifier<Customer> id;
  final String name;
  final String address;
  final String phoneNumber;
  final String? email;
  final bool isDeleted;

  const Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.email,
    this.isDeleted = false,
  });

  Customer copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    bool? isDeleted,
  }) => Customer(
    id: id,
    name: name ?? this.name,
    address: address ?? this.address,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: email ?? this.email,
    isDeleted: isDeleted ?? this.isDeleted,
  );

  int get contentHash =>
      name.hashCode ^
      address.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode << 10;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Customer && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
