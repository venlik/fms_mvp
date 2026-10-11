import 'package:finance_management_system/backend/details/customer_details_comparison.dart';
import 'package:finance_management_system/backend/models/identifier.dart';

class Customer with CustomerDetailsComparison implements Entity {
  final Identifier<Customer> id;
  @override
  final String name;
  final String address;
  @override
  final String phoneNumber;
  final String? email;
  final bool isDeleted;

  static const _notSet = Object();

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
    Object? email = _notSet,
    bool? isDeleted,
  }) => Customer(
    id: id,
    name: name ?? this.name,
    address: address ?? this.address,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: identical(email, _notSet) ? this.email : email as String?,
    isDeleted: isDeleted ?? this.isDeleted,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Customer && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
