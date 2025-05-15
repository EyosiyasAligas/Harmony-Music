import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/local_storage_constants.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _cachedToken;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveToken({required String tokenKey, required String? token}) async {
    await _secureStorage.write(
        key: tokenKey, value: token);
    if (tokenKey == LocalStorageConstants.accessToken) {
      _cachedToken = token;
    }
  }

  Future<String?> getToken({required String tokenKey}) async {
    if (_cachedToken != null && tokenKey == LocalStorageConstants.accessToken) {
      return _cachedToken;
    }

    return await _secureStorage.read(key: tokenKey);
  }

  Future<void> remove(String key) async {
    if (key == LocalStorageConstants.accessToken) {
      await _secureStorage.delete(key: key);
      _cachedToken = null;
    } else if (key == LocalStorageConstants.refreshToken) {
      await _secureStorage.delete(key: key);
    } else {
      await _prefs?.remove(key);
    }
  }

  bool isTokenExpired() {
    final expiresIn = _prefs?.getString(LocalStorageConstants.expiresIn);
    if (expiresIn == null) return true;

    final expirationDate = DateTime.parse(expiresIn);
    return expirationDate.isBefore(DateTime.now());
  }

  Future<void> clear() async {
    await Future.wait([
      _prefs?.clear() ?? Future.value(),
      _secureStorage.deleteAll(),
    ]);
    _cachedToken = null;
  }
}
