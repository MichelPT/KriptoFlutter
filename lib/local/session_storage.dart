import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {

  static void inputSession(String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', sessionToken);
  }

  static void removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token');
  }
}
