import 'package:flutter/material.dart';
import 'package:mypresensi/api/location%20helper.dart';
import '../model/attendance_model.dart';
import '../api/absen/absen_service.dart';

class RiwayatAbsensiScreen extends StatefulWidget {
  const RiwayatAbsensiScreen({super.key});

  @override
  State<RiwayatAbsensiScreen> createState() => _RiwayatAbsensiScreenState();
}

class _RiwayatAbsensiScreenState extends State<RiwayatAbsensiScreen> {
  List<Attendance> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  void fetchHistory() async {
    try {
      final data = await AbsenService.getHistory();
      final List<Attendance> parsed =
          data.map((json) => Attendance.fromJson(json)).toList();
      setState(() {
        history = parsed;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR FETCH HISTORY: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // 🔥 DELETE
  void deleteAbsen(int id) async {
    setState(() => isLoading = true);
    try {
      await AbsenService.deleteAbsen(id);
      fetchHistory();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                "Riwayat Absensi",
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: cs.primary))
                  : history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_toggle_off_rounded,
                                size: 64,
                                color: cs.onSurfaceVariant.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada riwayat absensi',
                                style: tt.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: history.length,
                          itemBuilder: (_, index) {
                            final item = history[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: cs.surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ================= HEADER =================
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: cs.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item.attendanceDate ?? '-',
                                              style: tt.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.map_outlined,
                                                size: 20,
                                                color: cs.primary,
                                              ),
                                              onPressed: () {},
                                              tooltip: "Lihat Map",
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: cs.error,
                                              ),
                                              tooltip: "Hapus",
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text("Hapus Absen"),
                                                    content: const Text(
                                                      "Yakin hapus absen ini?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context),
                                                        child: const Text("Batal"),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          if (item.id != null) {
                                                            deleteAbsen(item.id!);
                                                          }
                                                        },
                                                        style: FilledButton.styleFrom(
                                                          backgroundColor: cs.error,
                                                        ),
                                                        child: const Text("Hapus"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const Divider(height: 20),

                                    // ================= JAM =================
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _timeEntry(
                                            "Masuk",
                                            item.checkIn ?? '-',
                                            Icons.login_rounded,
                                            cs.primary,
                                            cs,
                                            tt,
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 36,
                                          color: cs.outlineVariant,
                                        ),
                                        Expanded(
                                          child: _timeEntry(
                                            "Keluar",
                                            item.checkOut ?? '-',
                                            Icons.logout_rounded,
                                            cs.tertiary,
                                            cs,
                                            tt,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // ================= LOKASI =================
                                    if (item.lat != null && item.lng != null) ...[
                                      const SizedBox(height: 12),
                                      FutureBuilder<String>(
                                        future: LocationHelper.getAddress(
                                          item.lat!,
                                          item.lng!,
                                        ),
                                        builder: (context, snapshot) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 14,
                                                color: cs.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  snapshot.data ?? "Memuat alamat...",
                                                  style: tt.bodySmall?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeEntry(
    String label,
    String time,
    IconData icon,
    Color color,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          time,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
