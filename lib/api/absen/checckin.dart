import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mypresensi/database/preference.dart';

class CheckinApi {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // 🔥 HEADER
  static Future<Map<String, String>> _headers() async {
    final token = await PreferenceHandler.getToken();

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ==============================
  // 🔥 CHECK IN
  // ==============================
  static Future<Map<String, dynamic>?> checkIn(double lat, double lng) async {
    final res = await http.post(
      Uri.parse("$baseUrl/absen/check-in"),
      headers: await _headers(),
      body: jsonEncode({"latitude": lat, "longitude": lng}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    } else {
      print("ERROR CHECKIN: ${res.body}");
      return null;
    }
  }

  // ==============================
  // 🔥 CHECK OUT
  // ==============================
  static Future<Map<String, dynamic>?> checkOut(double lat, double lng) async {
    final res = await http.post(
      Uri.parse("$baseUrl/absen/check-out"),
      headers: await _headers(),
      body: jsonEncode({"latitude": lat, "longitude": lng}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    } else {
      print("ERROR CHECKOUT: ${res.body}");
      return null;
    }
  }

  // ==============================
  // 🔥 TODAY
  // ==============================
  static Future<Map<String, dynamic>?> getToday(String date) async {
    final res = await http.get(
      Uri.parse("$baseUrl/absen/today?attendance_date=$date"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    }

    return null;
  }

  // ==============================
  // 🔥 STATS
  // ==============================
  static Future<Map<String, dynamic>> getStats(String start, String end) async {
    final res = await http.get(
      Uri.parse("$baseUrl/absen/stats?start=$start&end=$end"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    }

    return {};
  }
}
