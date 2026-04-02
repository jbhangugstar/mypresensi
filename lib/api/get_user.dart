import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/model/get_user_model.dart';

Future<GetUserModel> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse(Endpoint.user),
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  log(response.body);

  if (response.statusCode == 200) {
    return GetUserModel.fromJson(json.decode(response.body));
  } else {
    final error = GetUserModel.fromJson(json.decode(response.body));
    log(error.toString());

    throw Exception(error.message ?? "Gagal mengambil data user");
  }
}
