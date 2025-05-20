import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/crop_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CropService {
  final String getCrop = ApiEndpoints.getCrops;

  // Fetch crops for logged-in farmer
  Future<List<Crop>> getCrops() async {
    String? token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(getCrop),
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


  final String addcrop = ApiEndpoints.postCrop;
  // Add a new crop
  Future<bool> addCrop(Crop crop) async {
    String? token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(addcrop),
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
    final String deleteUrl = ApiEndpoints.deleteCrop(cropId.toString());
    String? token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse(deleteUrl),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // Update a crop
  Future<bool> updateCrop(int cropId) async {
    final String updatecrop = ApiEndpoints.updateCrop(cropId.toString());
    String? token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$updatecrop/$cropId"),
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
