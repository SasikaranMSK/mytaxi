import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user_json';
  static const _deviceIdKey = 'auth_device_id';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;

  TokenStorage(FlutterSecureStorage? secureStorage, SharedPreferences prefs)
      : _secureStorage = kIsWeb ? null : secureStorage,
        _prefs = prefs;

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage?.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _prefs.getString(_tokenKey);
    } else {
      return await _secureStorage?.read(key: _tokenKey);
    }
  }

  Future<void> saveUserJson(String userJson) async {
    if (kIsWeb) {
      await _prefs.setString(_userKey, userJson);
    } else {
      await _secureStorage?.write(key: _userKey, value: userJson);
    }
  }

  Future<String?> getUserJson() async {
    if (kIsWeb) {
      return _prefs.getString(_userKey);
    } else {
      return await _secureStorage?.read(key: _userKey);
    }
  }

  Future<void> saveDeviceId(String deviceId) async {
    if (kIsWeb) {
      await _prefs.setString(_deviceIdKey, deviceId);
    } else {
      await _secureStorage?.write(key: _deviceIdKey, value: deviceId);
    }
  }

  Future<String?> getDeviceId() async {
    if (kIsWeb) {
      return _prefs.getString(_deviceIdKey);
    } else {
      return await _secureStorage?.read(key: _deviceIdKey);
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      await _prefs.remove(_deviceIdKey);
    } else {
      await _secureStorage?.deleteAll();
    }
  }
}
