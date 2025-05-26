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
    return Crop(
      cropId: json['cropID'] as int? ?? 0,
      cropName: json['cropName']?.toString() ?? 'Unknown Crop',
      plantingSeason: json['plantingSeason']?.toString() ?? '',
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