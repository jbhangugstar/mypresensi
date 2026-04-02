import 'package:flutter/material.dart';
import 'view/login_screen.dart';
import 'view/register_screen.dart';
import 'view/profile_screen.dart';
import 'view/edit_profile_screen.dart';
import 'model/get_user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Presensi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => EditProfileScreen(
          user: ModalRoute.of(context)!.settings.arguments as GetUserData,
        ),
      },
    );
  }
}
