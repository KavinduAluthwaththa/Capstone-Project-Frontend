class Pesticide {
  int pesticideID;
  int cropID;
  String pesticideType;
  int recommendedAmount;

  Pesticide({
    required this.pesticideID,
    required this.cropID,
    required this.pesticideType,
    required this.recommendedAmount,
  });

  factory Pesticide.fromJson(Map<String, dynamic> json) {
    return Pesticide(
      pesticideID: json['pesticideID'],
      cropID: json['cropID'],
      pesticideType: json['pesticideType'],
      recommendedAmount: json['recommendedAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pesticideID': pesticideID,
      'cropID': cropID,
      'pesticideType': pesticideType,
      'recommendedAmount': recommendedAmount,
    };
  }
}
