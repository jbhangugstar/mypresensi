// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:mypresensi/api/absen/absen_service.dart';
// import 'package:mypresensi/model/absen_response_model.dart';

// class AbsenPage extends StatefulWidget {
//   const AbsenPage({super.key});

//   @override
//   State<AbsenPage> createState() => _AbsenPageState();
// }

// class _AbsenPageState extends State<AbsenPage> {
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   bool _isLoading = true;
//   bool _isAbsenLoading = false;
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Izin lokasi ditolak secara permanen')),
//         );
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _currentPosition = position;
//         _isLoading = false;
//         _markers.add(
//           Marker(
//             markerId: const MarkerId('current_location'),
//             position: LatLng(position.latitude, position.longitude),
//             infoWindow: const InfoWindow(title: 'Lokasi Anda'),
//           ),
//         );
//       });

//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//           LatLng(position.latitude, position.longitude),
//           15,
//         ),
//       );
//     } catch (e) {
//       log('Error getting location: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
//     }
//   }

//   Future<void> _handleCheckIn() async {
//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Lokasi belum tersedia')));
//       return;
//     }

//     setState(() {
//       _isAbsenLoading = true;
//     });

//     try {
//       final AbsenResponseModel? success = await AbsenService.checkIn(
//         latitude: _currentPosition!.latitude,
//         longitude: _currentPosition!.longitude,
//       );

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             success?.success == true
//                 ? 'Absen masuk berhasil'
//                 : 'Gagal absen masuk',
//           ),
//         ),
//       );
//     } catch (e) {
//       log('Check in error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Gagal check in: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAbsenLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleCheckOut() async {
//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Lokasi belum tersedia')));
//       return;
//     }

//     setState(() {
//       _isAbsenLoading = true;
//     });

//     try {
//       final success = await AbsenService.checkOut(
//         latitude: _currentPosition!.latitude,
//         longitude: _currentPosition!.longitude,
//       );

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             success.success ? 'Absen keluar berhasil' : 'Gagal absen keluar',
//           ),
//         ),
//       );
//     } catch (e) {
//       log('Check out error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Gagal check out: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAbsenLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Absen Masuk'), centerTitle: true),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _currentPosition != null
//                         ? LatLng(
//                             _currentPosition!.latitude,
//                             _currentPosition!.longitude,
//                           )
//                         : const LatLng(
//                             -6.2088,
//                             106.8456,
//                           ), // Jakarta sebagai default
//                     zoom: 15,
//                   ),
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                   },
//                   markers: _markers,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     children: [
//                       if (_currentPosition != null)
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Lokasi Anda',
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ],
//                           ),
//                         ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: _isAbsenLoading
//                                   ? null
//                                   : _handleCheckIn,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: _isAbsenLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Colors.white,
//                                             ),
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Absen Masuk',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: _isAbsenLoading
//                                   ? null
//                                   : _handleCheckOut,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: _isAbsenLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Colors.white,
//                                             ),
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Absen Keluar',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
