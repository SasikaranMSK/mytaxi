import 'package:flutter/widgets.dart';
import '../entities/auth_entity.dart';

abstract class AuthenticationRepository {
  Future<AuthEntity?> login({
    required String username,
    required String password,
    required String deviceId,
    BuildContext? context,
  });
  Future<void> logout();

  Future<String?> getUserToken();
  Future<AuthEntity?> getUserData();

  Future<void> clearUserData();
  Future<void> saveUserData(AuthEntity user);
}
