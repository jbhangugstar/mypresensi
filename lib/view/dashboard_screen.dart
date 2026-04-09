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
  String today = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now());

  // ================= MAP =================
  GoogleMapController? mapController;
  // Koordinat PPKD Jakarta Pusat
  LatLng currentPosition = const LatLng(-6.210710139945732, 106.81355394001878);
  String currentAddress = "PPKD Jakarta Pusat";
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

    // Set marker langsung agar peta muncul di PPKD tanpa menunggu GPS
    marker = Marker(
      markerId: const MarkerId("me"),
      position: currentPosition,
      infoWindow: const InfoWindow(
        title: "Lokasi Anda",
        snippet: "PPKD Jakarta Pusat",
      ),
    );

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
    // Coba minta permission (tidak blocking jika gagal)
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
    } catch (_) {
      // Abaikan error permission, tetap lanjut ke koordinat hardcode
    }

    // Koordinat PPKD Jakarta Pusat
    currentPosition = const LatLng(-6.2108069579377805, 106.81296578881235);

    String addressText = "PPKD Jakarta Pusat";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        addressText =
            "${place.name}, ${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (_) {
      // Fallback alamat
    }

    if (!mounted) return;

    setState(() {
      marker = Marker(
        markerId: const MarkerId("me"),
        position: currentPosition,
        infoWindow: InfoWindow(
          title: "Lokasi Anda",
          snippet: addressText,
        ),
      );

      currentAddress = addressText;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-in berhasil")),
      );

      fetchToday();
      fetchStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-in gagal: $e")),
      );
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
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-out berhasil")),
      );

      fetchToday();
      fetchStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-out gagal: $e")),
      );
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= GREETING HEADER =================
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoadingProfile ? greeting : "$greeting 👋",
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          userName,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                today,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 20),

              // ================= ABSENSI HARI INI =================
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Absensi Hari Ini",
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _timeChip(
                              "Masuk",
                              todayAttendance?.checkIn?.isEmpty ?? true
                                  ? '--:--'
                                  : todayAttendance!.checkIn!,
                              Icons.login_rounded,
                              cs.primary,
                              cs,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _timeChip(
                              "Pulang",
                              todayAttendance?.checkOut?.isEmpty ?? true
                                  ? '--:--'
                                  : todayAttendance!.checkOut!,
                              Icons.logout_rounded,
                              cs.tertiary,
                              cs,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= BUTTONS =================
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (sudahCheckIn || isLoadingAbsen) ? null : checkIn,
                      icon: isLoadingAbsen
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: const Text("Check In"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: (sudahCheckOut || isLoadingAbsen) ? null : checkOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Check Out"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= STATS =================
              Text(
                "Statistik Bulan Ini",
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              isLoadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "Hadir",
                            hadirCount,
                            Icons.check_circle_outline,
                            cs.primary,
                            cs.primaryContainer,
                            cs,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            "Izin",
                            izinCount,
                            Icons.event_note_outlined,
                            cs.tertiary,
                            cs.tertiaryContainer,
                            cs,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            "Absen",
                            absenCount,
                            Icons.cancel_outlined,
                            cs.error,
                            cs.errorContainer,
                            cs,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 20),

              // ================= MAP =================
              Text(
                "Lokasi Saat Ini",
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      currentAddress,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeChip(String label, String time, IconData icon, Color iconColor, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              Text(
                time,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, IconData icon, Color iconColor, Color bgColor, ColorScheme cs) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NAVIGATION =================
  Widget getBody() {
    if (currentIndex == 0) return dashboardView();
    if (currentIndex == 1) return const RiwayatAbsensiScreen();
    return ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          setState(() => currentIndex = i);
          if (i == 0) {
            loadUser();
            fetchToday();
            fetchStats();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "Riwayat",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
