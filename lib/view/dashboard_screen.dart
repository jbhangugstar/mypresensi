import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mypresensi/api/absen/absen_service.dart';
import 'package:mypresensi/api/auth/profile_user.dart';
import '../model/attendance_model.dart';
import 'riwayat_absensi_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  // ================= USER =================
  String greeting = '';
  String userName = 'User';
  bool isLoadingProfile = true;

  // ================= DATE =================
  String today = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

  // ================= MAP =================
  GoogleMapController? mapController;
  LatLng currentPosition = const LatLng(-6.200000, 106.816666);
  String currentAddress = "Loading...";
  Marker? marker;

  // ================= ABSEN =================
  bool isLoadingAbsen = false;
  Attendance? todayAttendance;

  // ================= STATS =================
  int hadirCount = 0;
  int izinCount = 0;
  int absenCount = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    setGreeting();
    loadUser();
    getCurrentLocation();
    fetchToday();
    fetchStats();
  }

  // ================= GREETING =================
  void setGreeting() {
    final hour = DateTime.now().hour;
    greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 18
        ? 'Selamat Siang'
        : 'Selamat Malam';
  }

  // ================= PROFILE =================
  void loadUser() async {
    try {
      final profile = await ProfileApi.getProfile();
      if (!mounted) return;

      setState(() {
        userName = profile.name;
        isLoadingProfile = false;
      });
    } catch (_) {
      setState(() => isLoadingProfile = false);
    }
  }

  // ================= LOCATION =================
  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = LatLng(pos.latitude, pos.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      marker = Marker(
        markerId: const MarkerId("me"),
        position: currentPosition,
        infoWindow: InfoWindow(
          title: "Lokasi Anda",
          snippet: "${place.street}, ${place.locality}",
        ),
      );

      currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}";

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition, 16),
      );
    });
  }

  // ================= CHECK IN =================
  void checkIn() async {
    setState(() => isLoadingAbsen = true);

    try {
      await AbsenService.checkIn(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        address: currentAddress,
        status: "masuk",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Check-in berhasil")));

      fetchToday();
      fetchStats();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Check-in gagal: $e")));
    }

    setState(() => isLoadingAbsen = false);
  }

  // ================= CHECK OUT =================
  void checkOut() async {
    setState(() => isLoadingAbsen = true);

    try {
      await AbsenService.checkOut(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        address: currentAddress,
        // status: "masuk",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Check-out berhasil")));

      fetchToday();
      fetchStats();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Check-out gagal: $e")));
    }

    setState(() => isLoadingAbsen = false);
  }

  // ================= TODAY =================
  void fetchToday() async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final data = await AbsenService.getToday(date);

      setState(() {
        todayAttendance = Attendance.fromJson(data);
      });
    } catch (_) {
      setState(() {
        todayAttendance = Attendance(checkIn: "", checkOut: "");
      });
    }
  }

  // ================= STATS =================
  void fetchStats() async {
    try {
      final now = DateTime.now();
      final start = DateFormat('yyyy-MM-01').format(now);
      final end = DateFormat('yyyy-MM-dd').format(now);

      final stats = await AbsenService.getStats(start, end);

      setState(() {
        hadirCount = stats['total_masuk'] ?? 0;
        izinCount = stats['total_izin'] ?? 0;
        absenCount = stats['total_absen'] ?? 0;
        isLoadingStats = false;
      });
    } catch (_) {
      setState(() => isLoadingStats = false);
    }
  }

  bool get sudahCheckIn =>
      todayAttendance?.checkIn != null && todayAttendance!.checkIn!.isNotEmpty;

  bool get sudahCheckOut =>
      todayAttendance?.checkOut != null &&
      todayAttendance!.checkOut!.isNotEmpty;

  // ================= DASHBOARD =================
  Widget dashboardView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade900],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              isLoadingProfile ? greeting : "$greeting, $userName 👋",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(today, style: const TextStyle(color: Colors.white70)),

            const SizedBox(height: 20),

            // ================= MAP =================
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition,
                    zoom: 14,
                  ),
                  markers: marker != null ? {marker!} : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(currentAddress, style: const TextStyle(color: Colors.white)),

            const SizedBox(height: 20),

            // ================= ABSENSI =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Absensi Hari Ini",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Masuk: ${todayAttendance?.checkIn?.isEmpty ?? true ? '--:--' : todayAttendance!.checkIn}",
                      ),
                      Text(
                        "Pulang: ${todayAttendance?.checkOut?.isEmpty ?? true ? '--:--' : todayAttendance!.checkOut}",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (sudahCheckIn || isLoadingAbsen)
                        ? null
                        : checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: isLoadingAbsen
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Check In"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (sudahCheckOut || isLoadingAbsen)
                        ? null
                        : checkOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Check Out"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= STATS =================
            isLoadingStats
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: statBox("Hadir", hadirCount, Colors.green),
                      ),
                      Expanded(
                        child: statBox("Izin", izinCount, Colors.orange),
                      ),
                      Expanded(child: statBox("Absen", absenCount, Colors.red)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget statBox(String title, int value, Color color) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ================= NAVIGATION =================
  Widget getBody() {
    if (currentIndex == 0) return dashboardView();
    if (currentIndex == 1) return RiwayatAbsensiScreen();
    return ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
