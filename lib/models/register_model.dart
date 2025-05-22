class RegisterModel {
  final String firstName;
  final String lastName;
  final String userName;
  final String password;
  final String confirmedPassword;
  final int userTypes;
  final String location;

  RegisterModel({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
    required this.confirmedPassword,
    required this.userTypes,
    required this.location,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      password: json['password'],
      confirmedPassword: json['confirmedPassword'],
      userTypes: json['userTypes'],
      location: json['Address']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'password': password,
      'confirmedPassword': confirmedPassword,
      'userTypes': userTypes,
      'Address': location,
    };
  }
}