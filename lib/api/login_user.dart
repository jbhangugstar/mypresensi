import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_model.dart';
import 'endpoint.dart';

class LoginUser {
  static const String tokenKey = 'auth_token';

  // fungsi login
  static Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {"Accept": "application/json"},
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final data = LoginResponse.fromJson(jsonData);

        // simpan token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, data.data.token);

        return data;
      } else {
        print("Login gagal: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }

  // ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}
