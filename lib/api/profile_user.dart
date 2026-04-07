import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/profile_model.dart';

class ProfileApi {
  static const String baseUrl = "https://appabsensi.mobileprojp.com";

  // ================= GET PROFILE =================
  static Future<ProfileModel> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        "Content-Type": "application/json",
        // ⚠️ kalau pakai token tambahin di sini
        // "Authorization": "Bearer YOUR_TOKEN"
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ProfileModel.fromJson(data['data']);
    } else {
      throw Exception("Gagal ambil profile");
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<bool> updateProfile(ProfileModel model) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    return res.statusCode == 200;
  }

  static Future<bool> uploadPhoto(String filePath) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/profile/photo'),
    );

    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    var res = await request.send();

    return res.statusCode == 200;
  }
}
