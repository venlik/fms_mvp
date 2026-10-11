import 'package:finance_management_system/backend/details/equatable.dart';
import 'package:finance_management_system/backend/models/logo.dart';

/// The fields that determine when two business profiles are the same.
///
/// A business is typically a singleton (the app's own profile), but
/// modelled as a collection. Two entries with the same content are
/// considered the same profile.
///
/// Included: all content fields.
/// Excluded: id (object identity), isDeleted (lifecycle).
class BusinessDetails with Equatable {
  final String name;
  final Logo? logo;
  final String phoneNumber;
  final String email;
  final String serviceLocation;
  final String configuredCurrency;

  const BusinessDetails({
    required this.name,
    required this.logo,
    required this.phoneNumber,
    required this.email,
    required this.serviceLocation,
    required this.configuredCurrency,
  });

  @override
  List<Object?> get props => [
    name,
    logo,
    phoneNumber,
    email,
    serviceLocation,
    configuredCurrency,
  ];

  @override
  String toString() => 'BusinessDetails(name: $name, phone: $phoneNumber)';
}