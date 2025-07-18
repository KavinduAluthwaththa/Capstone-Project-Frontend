class Crop {
  final int cropId;
  final String cropName;
  final String plantingSeason;

  Crop({
    required this.cropId,
    required this.cropName,
    required this.plantingSeason,
  });

  factory Crop.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    // Handle different possible field names from API
    // The API uses 'text' for crop name and 'value' for crop ID
    final id =
        json['value'] ??
        json['cropID'] ??
        json['CropID'] ??
        json['cropId'] ??
        json['id'] ??
        0;
    final name =
        json['text'] ??
        json['cropName'] ??
        json['CropName'] ??
        json['name'] ??
        json['Name'] ??
        'Unknown Crop';
    final season =
        json['plantingSeason'] ??
        json['PlantingSeason'] ??
        json['season'] ??
        '';

    return Crop(
      cropId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      cropName: name.toString(),
      plantingSeason: season.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropID': cropId,
      'cropName': cropName,
      'plantingSeason': plantingSeason,
    };
  }
}
