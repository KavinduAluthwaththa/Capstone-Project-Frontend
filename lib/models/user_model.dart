

class ApplicationUser {
  final String id;
  final String firstName;
  final String lastName;
  final String telephoneNo;
  final String address;

  ApplicationUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.telephoneNo,
    required this.address,
  });

  factory ApplicationUser.fromJson(Map<String, dynamic> json) {
    return ApplicationUser(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      telephoneNo: json['telephoneNo'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'telephoneNo': telephoneNo,
      'address': address,
    };
  }
}
