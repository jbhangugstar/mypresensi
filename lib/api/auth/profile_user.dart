import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mypresensi/database/preference.dart';
import '../../model/profile_model.dart';

class ProfileApi {
  // 🔥 Pakai baseUrl yang konsisten
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // 🔥 Headers dibuat sync (lebih clean)
  static Future<Map<String, String>> getHeaders() async {
    final token = await PreferenceHandler.getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // 🔥 GET PROFILE
  static Future<ProfileModel> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // 🔥 Flexible parsing (API kadang beda format)
      final profileJson =
          data is Map<String, dynamic> && data.containsKey('data')
          ? data['data']
          : data;

      return ProfileModel.fromJson(profileJson);
    } else {
      throw Exception("Gagal ambil profile: ${res.statusCode}");
    }
  }

  // 🔥 UPDATE PROFILE
  static Future<bool> updateProfile(ProfileModel model) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    return res.statusCode == 200;
  }

  // 🔥 UPLOAD PHOTO
  static Future<bool> uploadPhoto(String filePath) async {
    final String? token = await PreferenceHandler.getToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/profile/photo'),
    );

    request.headers.addAll({
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    });

    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    final res = await request.send();

    return res.statusCode == 200;
  }
}
