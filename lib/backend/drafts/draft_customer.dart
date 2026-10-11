// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/customer_details_comparison.dart';

class DraftCustomer with CustomerDetailsComparison {
  @override
  String name;
  String address;
  @override
  String phoneNumber;
  String? email;

  static const _notSet = Object();

  DraftCustomer({
    this.name = '',
    this.address = '',
    this.phoneNumber = '',
    this.email,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty;

  DraftCustomer copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    Object? email = _notSet,
  }) {
    return DraftCustomer(
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: identical(email, _notSet) ? this.email : email as String?,
    );
  }
}
