import 'package:finance_management_system/backend/models/identifier.dart';
import 'package:finance_management_system/backend/models/logo.dart';

// class Business({
//   required final Identifier<Business> id,
//   required final String name,
//   required final Logo? logo,
//   required final String phoneNumber,
//   required final String email,
//   required final String serviceLocation,
//   required final String configuredCurrency,
// }) implements Entity{}

class Business implements Entity {
  final Identifier<Business> id;
  final String name;
  final Logo? logo;
  final String phoneNumber;
  final String email;
  final String serviceLocation;
  final String configuredCurrency;
  final bool? isDeleted;

  const Business({
    required this.id,
    required this.name,
    required this.logo,
    required this.phoneNumber,
    required this.email,
    required this.serviceLocation,
    required this.configuredCurrency,
    this.isDeleted = false,
  });

  Business copyWith({
    String? name,
    Logo? logo,
    String? phoneNumber,
    String? email,
    String? serviceLocation,
    String? configuredCurrency,
    bool? isDeleted,
  }) => Business(
    id: id,
    name: name ?? this.name,
    logo: logo ?? this.logo,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: email ?? this.email,
    serviceLocation: serviceLocation ?? this.serviceLocation,
    configuredCurrency: configuredCurrency ?? this.configuredCurrency,
    isDeleted: isDeleted ?? this.isDeleted,
  );

  Business withoutLogo() => Business(
    id: id,
    name: name,
    logo: null,
    phoneNumber: phoneNumber,
    email: email,
    serviceLocation: serviceLocation,
    configuredCurrency: configuredCurrency,
    isDeleted: isDeleted,
  );

  ///hashes content{[name] + [phoneNumber] + [email]+ [serviceLocation]}
  ///useful for content equality
  int get contentHash =>
      name.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode ^
      serviceLocation.hashCode << 10;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Business && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
