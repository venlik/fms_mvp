// ignore_for_file: public_member_api_docs, sort_constructors_first
class DraftCustomer {
  String name;
  String address;
  String phoneNumber;
  String? email;

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

  int get contentHash =>
      name.hashCode ^
      address.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode << 10;

  DraftCustomer copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
  }) {
    return DraftCustomer(
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}
