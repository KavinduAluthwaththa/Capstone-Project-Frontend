import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/crop_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CropService {
  final String apiUrl = ApiEndpoints.getCrops;

  // Fetch crops for logged-in farmer
  Future<List<Crop>> getCrops() async {
    String? token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Crop.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch crops");
    }
  }

  // Add a new crop
  Future<bool> addCrop(Crop crop) async {
    String? token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(crop.toJson()),
    );

    return response.statusCode == 201;
  }

  // Delete a crop
  Future<bool> deleteCrop(int cropId) async {
    String? token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("$apiUrl/$cropId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // Get stored token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
