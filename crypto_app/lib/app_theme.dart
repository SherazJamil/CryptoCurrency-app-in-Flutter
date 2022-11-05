
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static bool isDarkEnabled = false;

  static Future<void> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkEnabled = prefs.getBool('isDark') ?? false;
  }
}