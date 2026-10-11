import 'package:finance_management_system/backend/details/business_details.dart';
import 'package:finance_management_system/backend/models/logo.dart';

mixin BusinessDetailsComparison {
  String get name;
  Logo? get logo;
  String get phoneNumber;
  String get email;
  String get serviceLocation;
  String get configuredCurrency;

  BusinessDetails get details => BusinessDetails(
    name: name,
    logo: logo,
    phoneNumber: phoneNumber,
    email: email,
    serviceLocation: serviceLocation,
    configuredCurrency: configuredCurrency,
  );
}