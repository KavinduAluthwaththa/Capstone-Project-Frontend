import 'farmer_model.dart';
import 'crop_model.dart';

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
