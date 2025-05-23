class Farmer {
  final int? farmerID;
  final String? name;
  final String? farmLocation;
  final String? phoneNumber;

  Farmer({
    this.farmerID,
    this.name,
    this.farmLocation,
    this.phoneNumber,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      farmerID: json['farmerID'] as int?,
      name: json['name'] as String? ?? 'Unknown', // Provide default value
      farmLocation: json['farmLocation'] as String? ?? 'Location not specified',
      phoneNumber: json['phoneNumber']?.toString() ?? 'Phone not available',
    );
  }
}