class Request {
  final int requestID;
  final String date;
  final int price;
  final int amount;
  final int cropID;
  final int shopID;

  Request({
    required this.requestID,
    required this.date,
    required this.price,
    required this.amount,
    required this.cropID,
    required this.shopID,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestID: json['requestID'],
      date: json['date'],
      price: json['price'],
      amount: json['amount'],
      cropID: json['cropID'],
      shopID: json['shopID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'date': date,
      'price': price,
      'amount': amount,
      'cropID': cropID,
      'shopID': shopID,
    };
  }
}