import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../model/training_model.dart';
import '../model/batch_model.dart';
import '../model/register_model.dart';

class RegisterApi {
  static const String baseUrl = "https://appabsensi.mobileprojp.com";

  // ================= GET TRAININGS =================
  static Future<List<TrainingModel>> getTrainings() async {
    final url = Uri.parse('$baseUrl/api/trainings');

    log("========== GET TRAININGS DEBUG ==========");
    log("URL: $url");

    final res = await http.get(url, headers: {"Accept": "application/json"});

    log("STATUS: ${res.statusCode}");
    log("BODY: ${res.body}");
    log("=========================================");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['data'];

      return list.map((e) => TrainingModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load trainings");
    }
  }

  // ================= GET ALL BATCH =================
  static Future<List<BatchModel>> getBatches() async {
    final url = Uri.parse('$baseUrl/api/batches');

    log("========== GET BATCHES DEBUG ==========");
    log("URL: $url");

    final res = await http.get(url, headers: {"Accept": "application/json"});

    log("STATUS: ${res.statusCode}");
    log("BODY: ${res.body}");
    log("=======================================");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['data'];

      return list.map((e) => BatchModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load batch");
    }
  }

  // ================= GET BATCH BY TRAINING =================
  static Future<List<BatchModel>> getBatchesByTraining(int trainingId) async {
    final url = Uri.parse('$baseUrl/api/batches?training_id=$trainingId');

    log("========== GET BATCH BY TRAINING DEBUG ==========");
    log("URL: $url");

    final res = await http.get(url, headers: {"Accept": "application/json"});

    log("STATUS: ${res.statusCode}");
    log("BODY: ${res.body}");
    log("=================================================");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['data'];

      return list.map((e) => BatchModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load batch by training");
    }
  }

  // ================= POST REGISTER =================
  static Future<bool> register(RegisterModel model) async {
    final url = Uri.parse('$baseUrl/api/register');
    final body = jsonEncode(model.toJson());

    log("========== REGISTER API DEBUG ==========");
    log("URL      : $url");
    log("BODY     : $body");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );

    log("STATUS   : ${res.statusCode}");
    log("BODY     : ${res.body}");
    log("HEADERS  : ${res.headers}");
    log("========================================");

    return res.statusCode == 200 || res.statusCode == 201;
  }
}
