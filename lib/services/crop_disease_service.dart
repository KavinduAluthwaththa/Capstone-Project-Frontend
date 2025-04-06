import 'dart:convert';
import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:capsfront/models/cropDisease_model.dart';
import 'package:http/http.dart' as http;

class CropDiseaseService {
  final String baseUrl = ApiEndpoints.getCropDiseases;

  Future<List<CropDisease>> getAllCropDiseases(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CropDisease.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load crop diseases");
    }
  }

  Future<bool> addCropDisease(CropDisease cropDisease, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(cropDisease.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> deleteCropDisease(int cdid, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$cdid'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  Future<bool> updateCropDisease(CropDisease cropDisease, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${cropDisease.cdid}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(cropDisease.toJson()),
    );

    return response.statusCode == 200;
  }
}
