import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypresensi/api/endpoint.dart';
import 'package:mypresensi/api/token_helper.dart';

Future<bool> deleteAbsen({required int id}) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse("${Endpoint.deleteAbsen}?id=$id"),
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  log(response.body);

  if (response.statusCode == 200) {
    return true;
  } else {
    final error = json.decode(response.body);
    log(error.toString());
    throw Exception(error['message'] ?? "Gagal menghapus absen");
  }
}
