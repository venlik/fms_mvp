// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/models/logo.dart';

class DraftBusiness {
  String name;
  Logo? logo;
  String phoneNumber;
  String email;
  String serviceLocation;
  String configuredCurrency;

  DraftBusiness({
    this.name = '',
    this.logo,
    this.phoneNumber = '',
    this.email = '',
    this.serviceLocation = '',
    this.configuredCurrency = 'KES',
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      serviceLocation.trim().isNotEmpty &&
      configuredCurrency.trim().isNotEmpty;

  DraftBusiness copyWith({
    String? name,
    Logo? logo,
    String? phoneNumber,
    String? email,
    String? serviceLocation,
    String? configuredCurrency,
  }) => DraftBusiness(
    name: name ?? this.name,
    logo: logo ?? this.logo,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: email ?? this.email,
    serviceLocation: serviceLocation ?? this.serviceLocation,
    configuredCurrency: configuredCurrency ?? this.configuredCurrency,
  );

  ///hashes content{[name] + [phoneNumber] + [email]+ [serviceLocation]}
  ///useful for content equality
  int get contentHash =>
      name.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode ^
      serviceLocation.hashCode << 10;

  @override
  bool operator ==(covariant DraftBusiness other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.logo == logo &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.serviceLocation == serviceLocation &&
        other.configuredCurrency == configuredCurrency;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        logo.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        serviceLocation.hashCode ^
        configuredCurrency.hashCode;
  }
}
