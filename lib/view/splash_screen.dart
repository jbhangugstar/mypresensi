import 'package:flutter/material.dart';
import 'package:mypresensi/database/preference.dart';
import 'package:mypresensi/extension/navigator.dart';
import 'package:mypresensi/view/dashboard_screen.dart';
import 'package:mypresensi/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await PreferenceHandler.getToken();

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Token exists, go to dashboard
        context.pushAndRemoveAll(DashboardScreen());
      } else {
        context.pushAndRemoveAll(LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'My Presensi',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
