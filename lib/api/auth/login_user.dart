import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mypresensi/database/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/login_model.dart';
import '../endpoint.dart';

class LoginUser {
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

      log("Login response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = LoginResponse.fromJson(jsonData);

        await PreferenceHandler().storingToken(data.data.token);

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

  static Future<void> logout() async {
    await PreferenceHandler().deleteToken();
  }
}
