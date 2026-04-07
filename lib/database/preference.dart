import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;
  PreferenceHandler._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // 🔑 Keys
  static const String _isLogin = 'isLogin';
  static const String _token = 'auth_token';
  static const String _isDarkMode = 'isDarkMode';

  // ======================
  // ✅ LOGIN
  // ======================

  Future<void> setLogin(String token) async {
    await _preferences.setBool(_isLogin, true);
    await _preferences.setString(_token, token);
  }

  Future<void> logout() async {
    await _preferences.remove(_isLogin);
    await _preferences.remove(_token);
  }

  // ======================
  // ✅ GET DATA
  // ======================

  bool get isLogin => _preferences.getBool(_isLogin) ?? false;

  String? get token => _preferences.getString(_token);

  // ======================
  // 🌙 DARK MODE
  // ======================

  Future<void> setDarkMode(bool isDarkMode) async {
    await _preferences.setBool(_isDarkMode, isDarkMode);
  }

  bool get isDarkMode => _preferences.getBool(_isDarkMode) ?? false;
}
