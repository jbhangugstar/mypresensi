import 'package:mypresensi/api/token_helper.dart';

Future<void> logoutUser() async {
  await removeToken();
}
