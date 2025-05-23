
class Request {
  final int requestID;
  final String cropName;
  final String date;
  final int price;
  final int amount;
  final int farmerID;
  final int shopID;

  Request({
    required this.requestID,
    required this.cropName,
    required this.date,
    required this.price,
    required this.amount,
    required this.farmerID,
    required this.shopID,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      cropName: json['cropName'],
      requestID: json['requestID'],
      date: json['date'],
      price: json['price'],
      amount: json['amount'],
      farmerID: json['farmerID'],
      shopID: json['shopID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'requestID': requestID,
      'date': date,
      'price': price,
      'amount': amount,
      'farmerID': farmerID,
      'shopID': shopID,
    };
  }
}