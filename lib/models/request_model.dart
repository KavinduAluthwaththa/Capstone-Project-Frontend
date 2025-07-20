class Request {
  final int requestID;
  final String date;
  final int price;
  final int amount;
  final int cropID;
  final int shopID;
  final bool isAvailable;

  Request({
    required this.requestID,
    required this.date,
    required this.price,
    required this.amount,
    required this.cropID,
    required this.shopID,
    required this.isAvailable,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    try {
      return Request(
        requestID: _parseIntValue(json['RequestID'] ?? json['requestID']),
        date: _parseStringValue(json['Date'] ?? json['date']),
        price: _parseIntValue(json['Price'] ?? json['price']),
        amount: _parseIntValue(json['Amount'] ?? json['amount']),
        cropID: _parseIntValue(json['CropID'] ?? json['cropID']),
        shopID: _parseIntValue(json['ShopID'] ?? json['shopID']),
        isAvailable: _parseBoolValue(
          json['IsAvailable'] ?? json['isAvailable'],
        ),
      );
    } catch (e) {
      print('Error parsing Request from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('Failed to parse int from string: $value');
        return 0;
      }
    }
    print('Unexpected type for int value: ${value.runtimeType} - $value');
    return 0;
  }

  static String _parseStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static bool _parseBoolValue(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'date': date,
      'price': price,
      'amount': amount,
      'cropID': cropID,
      'shopID': shopID,
      'isAvailable': isAvailable,
    };
  }
}
