class GrowingCrop {
  final int cfid;
  final int cropID;
  final int farmerID;
  final String date;
  final int amount;
  final Crop crop;
  final Farmer farmer;

  GrowingCrop({
    required this.cfid,
    required this.cropID,
    required this.farmerID,
    required this.date,
    required this.amount,
    required this.crop,
    required this.farmer,
  });

  factory GrowingCrop.fromJson(Map<String, dynamic> json) {
    return GrowingCrop(
      cfid: json['cfid'],
      cropID: json['cropID'],
      farmerID: json['farmerID'],
      date: json['date'],
      amount: json['amount'],
      crop: Crop.fromJson(json['crop']),
      farmer: Farmer.fromJson(json['farmer']),
    );
  }
}

class Crop {
  final int cropID;
  final String cropName;
  final String plantingSeason;

  Crop({
    required this.cropID,
    required this.cropName,
    required this.plantingSeason,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      cropID: json['cropID'],
      cropName: json['cropName'],
      plantingSeason: json['plantingSeason'],
    );
  }
}

class Farmer {
  final int farmerID;
  final String name;
  final String farmLocation;
  final int phoneNumber;
  final String email;

  Farmer({
    required this.farmerID,
    required this.name,
    required this.farmLocation,
    required this.phoneNumber,
    required this.email,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      farmerID: json['farmerID'],
      name: json['name'],
      farmLocation: json['farmLocation'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}