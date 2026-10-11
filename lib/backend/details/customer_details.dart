import 'package:finance_management_system/backend/details/equatable.dart';

/// The fields that determine when two customers are the same person.
///
/// Included:
///   • [name]        — who they are
///   • [phoneNumber] — how we disambiguate two "John Smith"s
///
/// Intentionally excluded:
///   • address — contact detail; can change without changing identity
///   • email   — contact detail; can change without changing identity
///   • isDeleted — lifecycle flag, not content
///
/// If the business rule for "same customer" changes, this is the
/// only file that needs to change.
class CustomerDetails with Equatable {
  final String name;
  final String phoneNumber;

  const CustomerDetails({required this.name, required this.phoneNumber});

  @override
  List<Object?> get props => [name, phoneNumber];

  @override
  String toString() => 'CustomerDetails(name: $name, phone: $phoneNumber)';
}