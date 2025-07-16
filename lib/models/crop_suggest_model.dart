class CropSuggestInput {
  final double n;
  final double p;
  final double k;
  final double ph;
  final double temperature;
  final int humidity;
  final double rainfall;
  final String location;

  CropSuggestInput({
    required this.n,
    required this.p,
    required this.k,
    required this.ph,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
        'n': n,
        'p': p,
        'k': k,
        'ph': ph,
        'temperature': temperature,
        'humidity': humidity,
        'rainfall': rainfall,
        'location': location,
      };
}