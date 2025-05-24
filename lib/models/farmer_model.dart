class Farmer {
  final int farmerID;
  final String name;
  final String farmLocation;
  final int phoneNumber;
  final String Email;

  Farmer({
    required this.farmerID,
    required this.name,
    required this.farmLocation,
    required this.phoneNumber,
    required this.Email,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
  return Farmer(
    farmerID: json['farmerID'],
    name: json['name'],
    farmLocation: json['farmLocation'],
    phoneNumber: json['phoneNumber'],
    Email: json['email'] ?? '',
  );
}
}
