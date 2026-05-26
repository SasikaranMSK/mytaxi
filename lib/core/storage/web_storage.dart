class WebStorage {
  static final Map<String, String> _mem = {};

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user_json';
  static const _deviceIdKey = 'auth_device_id';

  Future<void> write({required String key, required String value}) async {
    _mem[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _mem[key];
  }

  Future<void> delete({required String key}) async {
    _mem.remove(key);
  }

  Future<void> deleteAll() async {
    _mem.clear();
  }

  // Token storage methods
  Future<void> saveToken(String token) async =>
      write(key: _tokenKey, value: token);

  Future<String?> getToken() async => read(key: _tokenKey);

  Future<void> saveUserJson(String userJson) async =>
      write(key: _userKey, value: userJson);

  Future<String?> getUserJson() async => read(key: _userKey);

  Future<void> saveDeviceId(String deviceId) async =>
      write(key: _deviceIdKey, value: deviceId);

  Future<String?> getDeviceId() async => read(key: _deviceIdKey);

  Future<void> clearAll() async => deleteAll();
}
