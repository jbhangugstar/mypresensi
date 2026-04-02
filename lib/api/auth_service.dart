import 'package:mypresensi/api/login_user.dart';
import 'package:mypresensi/api/register_user.dart';
import 'package:mypresensi/api/get_user.dart';
import 'package:mypresensi/api/logout_user.dart';
import 'package:mypresensi/api/update_user.dart';
import 'package:mypresensi/model/login_model.dart';
import 'package:mypresensi/model/register_user_model.dart';
import 'package:mypresensi/model/get_user_model.dart';
import 'package:mypresensi/model/update_user_model.dart';

class AuthService {
  static Future<LoginModel?> login({
    required String email,
    required String password,
  }) async {
    return await loginUser(email: email, password: password);
  }

  static Future<RegisterModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await registerUser(name: name, email: email, password: password);
  }

  static Future<GetUserModel> getProfile() async {
    return await getUser();
  }

  static Future<void> logout() async {
    return await logoutUser();
  }

  static Future<UpdateUserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    return await updateUser(name: name, email: email);
  }
}
