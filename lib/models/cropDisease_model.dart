class CropDisease {
  final int? cdid;
  final int diseaseId;
  final String date;
  final int cropId;
  final String? cropName;  
  final String? diseaseName;

  CropDisease({
    this.cdid,
    required this.diseaseId,
    required this.date,
    required this.cropId,
    this.cropName,
    this.diseaseName,
  });

  factory CropDisease.fromJson(Map<String, dynamic> json) {
    return CropDisease(
      cdid: json['cdid'],
      diseaseId: json['DiseaseID'] ?? json['diseaseId'],
      date: json['Date'] ?? json['date'],
      cropId: json['CropID'] ?? json['cropId'],
      cropName: json['CropName'],
      diseaseName: json['DiseaseName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cdid': cdid,
      'DiseaseID': diseaseId,
      'Date': date,
      'CropID': cropId,
    };
  }
}
