import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/cropDisease_model.dart';
import 'package:http/http.dart' as http;

class CropDiseaseService {
  final String baseUrl = ApiEndpoints.getCropDiseases;

  // Fetch all crop diseases for logged-in farmer
  Future<List<CropDisease>> getAllCropDiseases(String token) async {
    final String getcd = ApiEndpoints.getCropDiseases;
    final response = await http.get(
      Uri.parse(getcd),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CropDisease.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load crop diseases");
    }
  }

  // Fetch crop disease by ID
  Future<bool> addCropDisease(CropDisease cropDisease, String token) async {
    final String sendcd = ApiEndpoints.postCropDisease;
    final response = await http.post(
      Uri.parse(sendcd),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(cropDisease.toJson()),
    );

    return response.statusCode == 201;
  }

  // Dlete crop disease by ID
  Future<bool> deleteCropDisease(int cdid, String token) async {
    final String delcd = ApiEndpoints.deleteCropDisease(cdid.toString());
    final response = await http.delete(
      Uri.parse('$delcd/$cdid'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // Update crop disease by ID
  Future<bool> updateCropDisease(CropDisease cropDisease,int cdid, String token) async {
    final String updatecd = ApiEndpoints.updateCropDisease(cdid.toString());
    final response = await http.put(
      Uri.parse('$updatecd/$cdid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(cropDisease.toJson()),
    );

    return response.statusCode == 200;
  }
}
