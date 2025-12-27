import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;

  // Initialize
  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // User Session
  static Future<void> saveUserSession({
    required String userId,
    required String email,
  }) async {
    await _preferences?.setBool(AppConstants.keyIsLoggedIn, true);
    await _preferences?.setString(AppConstants.keyUserId, userId);
    await _preferences?.setString(AppConstants.keyUserEmail, email);
  }

  static Future<void> clearUserSession() async {
    await _preferences?.clear();
  }

  static bool get isLoggedIn {
    return _preferences?.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  static String? get userId {
    return _preferences?.getString(AppConstants.keyUserId);
  }

  static String? get userEmail {
    return _preferences?.getString(AppConstants.keyUserEmail);
  }

  // General storage methods
  static Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  static String? getString(String key) {
    return _preferences?.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }
}