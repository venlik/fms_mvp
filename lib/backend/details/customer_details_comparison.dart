import 'package:finance_management_system/backend/details/customer_details.dart';

/// Implemented by anything that can be identified as a customer in
/// the real-world sense. Both [Customer] and [DraftCustomer] mix this
/// in, so repositories can compare them uniformly without knowing
/// which is which.
mixin CustomerDetailsComparison {
  /// The fields that participate in the identity projection.
  /// Any class mixing this in must expose them.
  String get name;
  String get phoneNumber;

  /// The content-significance view of this customer.
  CustomerDetails get details => CustomerDetails(
    name: name.toLowerCase().trim(),
    phoneNumber: phoneNumber.trim(),
  );
}
