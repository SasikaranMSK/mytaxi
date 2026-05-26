import 'dart:convert';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_model.dart';

class AuthenticationLocalDataSource {
  final TokenStorage _tokenStorage;

  AuthenticationLocalDataSource(this._tokenStorage);

  Future<void> saveAuthData(AuthModel user) async {
    // Store token separately; store sanitized user payload (no token).
    final sanitized = user.copyWith(token: null);
    final userJson = jsonEncode(sanitized.toJson());

    await Future.wait([
      _tokenStorage.saveToken(user.token ?? ''),
      _tokenStorage.saveDeviceId(user.deviceId ?? ''),
      _tokenStorage.saveUserJson(userJson),
    ]);
  }

  Future<void> saveDeviceId(String deviceId) async =>
      _tokenStorage.saveDeviceId(deviceId);

  Future<String?> getToken() => _tokenStorage.getToken();
  Future<String?> getDeviceId() => _tokenStorage.getDeviceId();

  Future<String?> getUserName() async {
    final model = await getUserData();
    return model?.username;
  }

  Future<AuthModel?> getUserData() async {
    final jsonString = await _tokenStorage.getUserJson();
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final model = AuthModel.fromJson(jsonDecode(jsonString));
      final token = await _tokenStorage.getToken();
      final deviceId = await _tokenStorage.getDeviceId();
      return model.copyWith(
        token: token ?? model.token,
        deviceId: deviceId ?? model.deviceId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _tokenStorage.clearAll();
  }
}
