import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AbsenMapScreen extends StatefulWidget {
  const AbsenMapScreen({super.key});

  @override
  State<AbsenMapScreen> createState() => _AbsenMapScreenState();
}

class _AbsenMapScreenState extends State<AbsenMapScreen> {
  LatLng? currentLatLng;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Lokasi Anda")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: currentLatLng!, zoom: 17),
        markers: {
          Marker(markerId: const MarkerId("me"), position: currentLatLng!),
        },
      ),
    );
  }
}
