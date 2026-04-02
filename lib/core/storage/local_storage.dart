import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tokens
  static Future<void> saveAccessToken(String token) async =>
      _prefs.setString('access_token', token);
  static String? getAccessToken() => _prefs.getString('access_token');

  static Future<void> saveRefreshToken(String token) async =>
      _prefs.setString('refresh_token', token);
  static String? getRefreshToken() => _prefs.getString('refresh_token');

  static Future<void> clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }

  // User info
  static Future<void> saveUserId(String id) async =>
      _prefs.setString('user_id', id);
  static String? getUserId() => _prefs.getString('user_id');

  static Future<void> saveUserRole(String role) async =>
      _prefs.setString('user_role', role);
  static String? getUserRole() => _prefs.getString('user_role');

  // Onboarding
  static Future<void> setOnboardingComplete() async =>
      _prefs.setBool('onboarding_complete', true);
  static bool isOnboardingComplete() =>
      _prefs.getBool('onboarding_complete') ?? false;

  // QR Update tracking (popup tous les 15 jours)
  static Future<void> saveLastQrUpdateCheck() async =>
      _prefs.setString('last_qr_check', DateTime.now().toIso8601String());

  static bool shouldShowQrUpdatePrompt() {
    final last = _prefs.getString('last_qr_check');
    if (last == null) return true;
    try {
      final diff = DateTime.now().difference(DateTime.parse(last));
      return diff.inDays >= 15;
    } catch (_) {
      return true;
    }
  }

  static Future<void> dismissQrUpdatePrompt() async =>
      saveLastQrUpdateCheck();

  // Photo de profil
  static Future<void> saveProfileImagePath(String path) async =>
      _prefs.setString('profile_image_path', path);
  static String? getProfileImagePath() =>
      _prefs.getString('profile_image_path');

  // Clear all
  static Future<void> clearAll() async => _prefs.clear();
}
