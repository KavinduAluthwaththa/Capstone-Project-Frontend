class Shop {
  final int shopID;
  final String name;
  final String phoneNumber;
  final String location;

  Shop({
    required this.shopID,
    required this.name,
    required this.phoneNumber,
    required this.location,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopID: json['shopID'],
      name: json['name'],
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone_number']?.toString() ?? '',
      location: json['location'] ?? '',
    );
  }
}