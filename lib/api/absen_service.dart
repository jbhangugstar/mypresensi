import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mypresensi/model/absen_response_model.dart';

class AbsenService {
  static const String baseUrl = "https://appabsensi.mobileprojp.com";

  static Future<AbsenResponseModel> checkIn({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/absen/check-in');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    final data = jsonDecode(response.body);

    return AbsenResponseModel.fromJson(data);
  }

  static Future<AbsenResponseModel> checkOut({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/absen/check-out');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    final data = jsonDecode(response.body);

    return AbsenResponseModel.fromJson(data);
  }
}
