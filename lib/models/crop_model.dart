class Crop {
  final int? id;
  final String cropName;
  final String plantingSeason;
  final String farmerId;  // Farmer's unique ID

  Crop({this.id, required this.cropName, required this.plantingSeason, required this.farmerId});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['CropID'],
      cropName: json['CropName'],
      plantingSeason: json['PlantingSeason'],
      farmerId: json['FarmerID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CropID': id,
      'CropName': cropName,
      'PlantingSeason': plantingSeason,
      'FarmerID': farmerId,
    };
  }
}
