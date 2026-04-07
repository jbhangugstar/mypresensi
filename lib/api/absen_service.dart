import 'package:mypresensi/api/check_in.dart';
import 'package:mypresensi/api/check_out.dart';
import 'package:mypresensi/model/absen_model.dart';

class AbsenService {
  static Future<AbsenModel?> absenMasuk({
    required String latitude,
    required String longitude,
  }) async {
    return await checkIn(latitude: latitude, longitude: longitude);
  }

  static Future<AbsenModel?> absenPulang({
    required String latitude,
    required String longitude,
  }) async {
    return await checkOut(latitude: latitude, longitude: longitude);
  }
}
