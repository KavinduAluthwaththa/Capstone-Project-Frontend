class Farmer {
  final int? farmerID;
  final String name;
  final String farmLocation;
  final String phoneNumber;

  Farmer({this.farmerID, required this.name, required this.farmLocation, required this.phoneNumber});

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      farmerID: json['farmerID'],
      name: json['name'],
      farmLocation: json['farmLocation'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmerID': farmerID,
      'name': name,
      'farmLocation': farmLocation,
      'phoneNumber': phoneNumber,
    };
  }
}
