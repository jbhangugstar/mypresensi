import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mypresensi/api/absen_service.dart';
import 'package:mypresensi/api/profile_user.dart';
import 'package:mypresensi/model/profile_model.dart';
import '../view/map_screen.dart' as map_view;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProfileModel? user;
  bool isLoading = true;
  bool isAbsenLoading = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      await getUserData();
      await getCurrentLocation();
    } catch (e) {
      log("LOAD DASHBOARD ERROR: $e");
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserData() async {
    try {
      final result = await ProfileApi.getProfile();
      if (!mounted) return;
      setState(() {
        user = result;
      });
    } catch (e) {
      log("GET USER ERROR: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS belum aktif");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin lokasi ditolak");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak permanen");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    log("LATITUDE: $latitude");
    log("LONGITUDE: $longitude");
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  String getTodayDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  Future<void> handleCheckIn() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi belum tersedia")));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      isAbsenLoading = true;
    });

    try {
      final result = await AbsenService.checkIn(
        latitude: latitude!,
        longitude: longitude!,
      );

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      log("CHECK IN ERROR: $e");
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Gagal check in: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isAbsenLoading = false;
        });
      }
    }
  }

  Future<void> handleCheckOut() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi belum tersedia")));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      isAbsenLoading = true;
    });

    try {
      final result = await AbsenService.checkOut(
        latitude: latitude!,
        longitude: longitude!,
      );

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      log("CHECK OUT ERROR: $e");
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Gagal check out: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isAbsenLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Absensi"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${getGreeting()},",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? "User",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getTodayDate(),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            "Lokasi Saat Ini",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text("Latitude : ${latitude ?? '-'}"),
                      Text("Longitude: ${longitude ?? '-'}"),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (latitude != null && longitude != null)
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => map_view.MapScreen(
                                        latitude: latitude!,
                                        longitude: longitude!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.map),
                          label: const Text("Lihat di Google Map"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi User",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("Nama    : ${user?.name ?? '-'}"),
                      Text("Email   : ${user?.email ?? '-'}"),
                      Text("User ID : ${user?.id ?? '-'}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isAbsenLoading ? null : handleCheckIn,
                  icon: const Icon(Icons.login),
                  label: Text(
                    isAbsenLoading ? "Loading..." : "Absen Masuk",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isAbsenLoading ? null : handleCheckOut,
                  icon: const Icon(Icons.logout),
                  label: Text(
                    isAbsenLoading ? "Loading..." : "Absen Pulang",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await loadDashboard();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh Lokasi & Data"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
