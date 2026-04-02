import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/api/token_helper.dart';
import 'package:mypresensi/model/update_user_model.dart';

Future<UpdateUserModel> updateUser({
  required String name,
  required String email,
}) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse(Endpoint.user),
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    body: {"name": name, "email": email},
  );

  log(response.body);

  if (response.statusCode == 200) {
    return UpdateUserModel.fromJson(json.decode(response.body));
  } else {
    final error = UpdateUserModel.fromJson(json.decode(response.body));
    log(error.toString());

    throw Exception(error.message ?? "Gagal update user");
  }
}
