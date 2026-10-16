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
    name: name.toLowerCase().trim(),
    logo: logo,
    phoneNumber: phoneNumber.trim(),
    email: email.toLowerCase().trim(),
    serviceLocation: serviceLocation.toLowerCase().trim(),
    configuredCurrency: configuredCurrency.trim(),
  );
}
