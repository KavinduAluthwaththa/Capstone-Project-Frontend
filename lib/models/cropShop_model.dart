class CropShop {
  int csid;
  int cropID;
  int shopID;
  String date;

  // Optional nested objects if needed
  Crop? crop;
  Shop? shop;

  CropShop({
    required this.csid,
    required this.cropID,
    required this.shopID,
    required this.date,
    this.crop,
    this.shop,
  });

  factory CropShop.fromJson(Map<String, dynamic> json) {
    return CropShop(
      csid: json['csid'],
      cropID: json['cropID'],
      shopID: json['shopID'],
      date: json['date'],
      crop: json['crop'] != null ? Crop.fromJson(json['crop']) : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'csid': csid,
      'cropID': cropID,
      'shopID': shopID,
      'date': date,
    };
    if (crop != null) data['crop'] = crop!.toJson();
    if (shop != null) data['shop'] = shop!.toJson();
    return data;
  }
}

// You can define Crop and Shop classes similarly if needed
class Crop {
  int id;
  String name;

  Crop({required this.id, required this.name});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Shop {
  int id;
  String name;

  Shop({required this.id, required this.name});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
