class CropRecommendation {
  final String cropName;
  final double confidence;
  final int rank;
  
  CropRecommendation({
    required this.cropName,
    required this.confidence,
    required this.rank,
  });
}