import 'package:capsfront/models/crop_model.dart';
import 'package:capsfront/models/farmer_model.dart';

class GrowingCrop {
  final int cfid;
  final int cropId;
  final int farmerId;
  final String date;
  final int amount;
  final Crop crop;
  final Farmer farmer;

  GrowingCrop({
    required this.cfid,
    required this.cropId,
    required this.farmerId,
    required this.date,
    required this.amount,
    required this.crop,
    required this.farmer,
  });

  factory GrowingCrop.fromJson(Map<String, dynamic> json) {
    return GrowingCrop(
      cfid: json['cfid'] as int? ?? 0,
      cropId: json['cropID'] as int? ?? 0,
      farmerId: json['farmerID'] as int? ?? 0,
      date: json['date']?.toString() ?? '', // Handle null and non-String values
      amount: json['amount'] as int? ?? 0,
      crop: Crop.fromJson(json['crop'] as Map<String, dynamic>? ?? {}),
      farmer: Farmer.fromJson(json['farmer'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'cfid': cfid,
    'cropID': cropId,
    'farmerID': farmerId,
    'date': date,
    'amount': amount,
    'crop': crop.toJson(),
    'farmer': farmer.toJson(),
  };
}

}