class ShopOwner {
  final int? ShopID;
  final String Type;
  final String PhoneNumber;
  final String Location;

  ShopOwner({this.ShopID, required this.Type, required this.PhoneNumber, required this.Location});

  factory ShopOwner.fromJson(Map<String, dynamic> json) {
    return ShopOwner(
      ShopID: json['ShopID'],
      Type: json['Type'],
      PhoneNumber: json['PhoneNumber'],
      Location: json['Location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShopID': ShopID,
      'Type': Type,
      'PhoneNumber': PhoneNumber,
      'Location': Location,
    };
  }
}
