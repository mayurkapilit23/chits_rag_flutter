import 'dart:convert';

import 'package:chatgpt_clone/features/auth/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String KEY_USER = "user_data";
  static const String KEY_IS_LOGGED_IN = "isLoggedIn";

  // Save whole model
  static Future<void> saveUser(LoginResponseModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(KEY_USER, jsonEncode(user.toJson()));
    await prefs.setBool(KEY_IS_LOGGED_IN, true);
  }

  // Load user
  static Future<LoginResponseModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(KEY_USER);

    if (jsonString == null) return null;

    return LoginResponseModel.fromJson(jsonDecode(jsonString));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_IS_LOGGED_IN) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
