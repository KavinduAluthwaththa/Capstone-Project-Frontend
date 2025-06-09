class DiseaseResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final String treatment;
  final String severity;

  DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.treatment,
    required this.severity,
  });
}