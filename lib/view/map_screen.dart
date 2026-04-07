import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final LatLng userLocation = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: const Text("Lokasi Saya")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: userLocation, zoom: 17),
        markers: {
          Marker(
            markerId: const MarkerId("user_location"),
            position: userLocation,
            infoWindow: const InfoWindow(title: "Lokasi Anda"),
          ),
        },
      ),
    );
  }
}
