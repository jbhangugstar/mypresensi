import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/api/token_helper.dart';
import 'package:mypresensi/model/login_model.dart';

Future<LoginModel?> loginUser({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse(Endpoint.login),
    headers: {"Accept": "application/json"},
    body: {"email": email, "password": password},
  );

  log(response.body);

  if (response.statusCode == 200) {
    final result = LoginModel.fromJson(json.decode(response.body));

    if (result.data != null) {
      await saveToken(result.data!.token!);
    }

    return result;
  } else {
    final error = LoginModel.fromJson(json.decode(response.body));
    log(error.toString());

    throw Exception(error.message ?? "Login gagal");
  }
}
