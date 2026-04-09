import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mypresensi/database/preference.dart';
import 'package:mypresensi/view/login_screen.dart';

final ValueNotifier<bool> themeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await PreferenceHandler().init();
  final isDark = await PreferenceHandler.getTheme();
  themeNotifier.value = isDark;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        final seedColor = const Color(0xFF1565C0); // M3 Deep Blue
        return MaterialApp(
          title: 'MyPresensi',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColor,
            brightness: Brightness.light,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 70,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColor,
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 70,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
