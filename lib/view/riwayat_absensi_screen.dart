import 'package:flutter/material.dart';
import 'package:mypresensi/api/location%20helper.dart';
import '../api/absen/absen_service.dart';
import '../model/attendance_model.dart';
// import '../utils/location_helper.dart';
import 'absen_page.dart';

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
      // final data = await AbsenService.getHistory();
      // setState(() {
      //   history = data;
      //   isLoading = false;
      // });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // 🔥 DELETE
  void deleteAbsen(int id) async {
    // await AbsensiService.deleteAbsen(id);
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : history.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat absensi',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (_, index) {
                final item = history[index];

                return GestureDetector(
                  onTap: () {
                    // 🔥 BUKA MAP DALAM APP
                    // if (item.lat != null && item.lng != null) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) => AbsenPage(
                    //         // lat: item.latitude!,
                    //         // lng: item.longitude!,
                    //         // type: "history",
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= HEADER =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text(
                            //   item.attendanceDate ?? '-',
                            //   style: const TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 18,
                                  color: Colors.blue,
                                ),

                                // 🔥 DELETE BUTTON
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Hapus"),
                                        content: const Text(
                                          "Yakin hapus absen ini?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);

                                              // ⚠️ sementara pakai index
                                              deleteAbsen(index + 1);
                                            },
                                            child: const Text(
                                              "Hapus",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
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

                        const SizedBox(height: 12),

                        // ================= JAM =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _timeBox(
                              "Masuk",
                              item.checkIn ?? '-',
                              Colors.green,
                            ),
                            _timeBox(
                              "Keluar",
                              item.checkOut ?? '-',
                              Colors.red,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ================= LOKASI =================
                        if (item.lat != null && item.lng != null)
                          FutureBuilder<String>(
                            future: LocationHelper.getAddress(
                              item.lat!,
                              item.lng!,
                            ),
                            builder: (context, snapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data ?? "Mengambil alamat...",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${item.lat!.toStringAsFixed(6)}, ${item.lng!.toStringAsFixed(6)}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _timeBox(String title, String time, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
