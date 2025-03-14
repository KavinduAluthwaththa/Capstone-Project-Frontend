import '../enums/user_types.dart';

class ApplicationUser {
  final String id;
  final String firstName;
  final String lastName;
  final String telephoneNo;
  final String address;
  final UserTypes userType;

  ApplicationUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.telephoneNo,
    required this.address,
    required this.userType,
  });

  factory ApplicationUser.fromJson(Map<String, dynamic> json) {
    return ApplicationUser(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      telephoneNo: json['telephoneNo'],
      address: json['address'],
      userType: userTypesFromJson(json['userType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'telephoneNo': telephoneNo,
      'address': address,
      'userType': userTypesToJson(userType),
    };
  }
}
