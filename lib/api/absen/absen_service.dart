import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/database/preference.dart';
import 'package:mypresensi/model/absen_response_model.dart';

class AbsenService {
  static const String baseUrl = Endpoint.baseUrl;

  static Future<AbsenResponseModel> checkIn({
    required double latitude,
    required double longitude,
    required String address,
    String status = "masuk", // default masuk
    String? alasanIzin,
  }) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/check-in');
    final now = DateTime.now();
    log(url.toString());

    final body = {
      "attendance_date": DateFormat('yyyy-MM-dd').format(now),
      "check_in": DateFormat('HH:mm').format(now),
      "check_in_lat": latitude.toString(),
      "check_in_lng": longitude.toString(),
      "check_in_address": address,
      "status": status,
      if (status == "izin") "alasan_izin": alasanIzin ?? "",
    };
    log(body.toString());
    final response = await http.post(
      url,
      headers: {"Accept": "application/json", 'Authorization': 'Bearer $token'},
      body: body,
    );
    log(response.request.toString());
    log(response.headers.toString());
    log(response.body);
    log(response.statusCode.toString());
    final data = jsonDecode(response.body);
    log(data.toString());
    if (response.statusCode == 200) {
      return AbsenResponseModel.fromJson(data);
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<AbsenResponseModel> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/check-out');

    final now = DateTime.now();

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", 'Authorization': 'Bearer $token'},

      body: {
        "attendance_date": DateFormat('yyyy-MM-dd').format(now),
        "check_out": DateFormat('HH:mm').format(now),
        "check_out_lat": latitude.toString(),
        "check_out_lng": longitude.toString(),
        "check_out_location": "$latitude, $longitude",
        "check_out_address": address,
      },
    );

    final data = jsonDecode(response.body);
    log(data.toString());
    if (response.statusCode == 200) {
      return AbsenResponseModel.fromJson(data);
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<Map<String, dynamic>> getToday(String date) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/today?attendance_date=$date');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<Map<String, dynamic>> getStats(String start, String end) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/stats?start=$start&end=$end');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<List<dynamic>> getHistory() async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/history');

    log("========== GET HISTORY DEBUG ==========");
    log("URL: $url");
    log("TOKEN: $token");

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    log("STATUS: ${response.statusCode}");
    log("BODY: ${response.body}");
    log("=======================================");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Handle berbagai kemungkinan format respons API
      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) {
            return inner;
          } else if (inner is Map && inner.containsKey('data')) {
            // Paginated: { data: { data: [...] } }
            return inner['data'] ?? [];
          }
        }
        return [];
      }
      return [];
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil riwayat');
    }
  }

  static Future<bool> deleteAbsen(int id) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse('$baseUrl/absen/$id');

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal menghapus');
    }
  }
}
