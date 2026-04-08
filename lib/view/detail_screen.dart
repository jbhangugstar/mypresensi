import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AbsenDetailScreen extends StatelessWidget {
  final double lat;
  final double long;
  final String type; // checkin / checkout

  const AbsenDetailScreen({
    super.key,
    required this.lat,
    required this.long,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, long);

    return Scaffold(
      appBar: AppBar(
        title: Text(type == "in" ? "Detail Check In" : "Detail Check Out"),
      ),
      body: Column(
        children: [
          // 🔥 GOOGLE MAP
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 17),
              markers: {
                Marker(markerId: const MarkerId("me"), position: position),
              },
            ),
          ),

          // 🔥 INFO
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Latitude: $lat"),
                Text("Longitude: $long"),
                const SizedBox(height: 10),
                Text(
                  type == "in" ? "Berhasil Check In" : "Berhasil Check Out",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
