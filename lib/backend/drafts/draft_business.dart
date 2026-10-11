// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:finance_management_system/backend/details/business_details_comparison.dart';
import 'package:finance_management_system/backend/models/logo.dart';

class DraftBusiness with BusinessDetailsComparison {
  @override
  String name;
  @override
  Logo? logo;
  @override
  String phoneNumber;
  @override
  String email;
  @override
  String serviceLocation;
  @override
  String configuredCurrency;
  static const _notSet = Object();

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
    Object? logo = _notSet,
    String? phoneNumber,
    String? email,
    String? serviceLocation,
    String? configuredCurrency,
  }) => DraftBusiness(
    name: name ?? this.name,
    logo: identical(logo, _notSet) ? this.logo : logo as Logo?,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: email ?? this.email,
    serviceLocation: serviceLocation ?? this.serviceLocation,
    configuredCurrency: configuredCurrency ?? this.configuredCurrency,
  );
}
