import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tokens
  static Future<void> saveAccessToken(String token) async {
    await _prefs.setString('access_token', token);
  }

  static String? getAccessToken() {
    return _prefs.getString('access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs.setString('refresh_token', token);
  }

  static String? getRefreshToken() {
    return _prefs.getString('refresh_token');
  }

  // Nettoyer les tokens (pour logout ou erreur 401)
  static Future<void> clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }

  // User info
  static Future<void> saveUserId(String id) async {
    await _prefs.setString('user_id', id);
  }

  static String? getUserId() {
    return _prefs.getString('user_id');
  }

  static Future<void> saveUserRole(String role) async {
    await _prefs.setString('user_role', role);
  }

  static String? getUserRole() {
    return _prefs.getString('user_role');
  }

  // Onboarding
  static Future<void> setOnboardingComplete() async {
    await _prefs.setBool('onboarding_complete', true);
  }

  static bool isOnboardingComplete() {
    return _prefs.getBool('onboarding_complete') ?? false;
  }

  // Clear all
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
