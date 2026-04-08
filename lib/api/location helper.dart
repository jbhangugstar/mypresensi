import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static Future<String> getAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      final place = placemarks.first;

      return "${place.street}, ${place.locality}";
    } catch (e) {
      return "Lokasi tidak ditemukan";
    }
  }
}
