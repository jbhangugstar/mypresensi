import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/model/register_user_model.dart';

Future<RegisterModel?> registerUser({
  required String name,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse(Endpoint.register),
    headers: {"Accept": "application/json"},
    body: {"name": name, "email": email, "password": password},
  );

  log(response.body);

  if (response.statusCode == 200) {
    return RegisterModel.fromJson(json.decode(response.body));
  } else {
    final error = RegisterModel.fromJson(json.decode(response.body));
    log(error.toString());

    throw Exception(error.message ?? "Register gagal");
  }
}
