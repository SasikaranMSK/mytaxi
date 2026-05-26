/// Stub for WebStorage - not used on non-web platforms
class WebStorage {
  Future<void> saveToken(String token) async {}
  Future<String?> getToken() async => null;
  Future<void> saveUserJson(String userJson) async {}
  Future<String?> getUserJson() async => null;
  Future<void> saveDeviceId(String deviceId) async {}
  Future<String?> getDeviceId() async => null;
  Future<void> clearAll() async {}
}
