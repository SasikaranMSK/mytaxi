import 'package:flutter/widgets.dart';
import '../../../../core/services/route_persistence_service.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/entities/auth_entity.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dto/login_request_dto.dart';
import '../mappers/auth_mapper.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final RoutePersistenceService _routePersistenceService;

  AuthenticationRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._routePersistenceService,
  );

  @override
  Future<AuthEntity?> login({
    required String username,
    required String password,
    required String deviceId,
    BuildContext? context,
  }) async {
    final request = LoginRequestDto(
      username: username,
      password: password,
      macAddress: deviceId,
    );

    final loginResponse = await _remoteDataSource.login(request, context);
    if (loginResponse == null) return null;

    final model = loginResponse.toModel().copyWith(deviceId: deviceId);
    await _localDataSource.saveAuthData(model);
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    final token = await _localDataSource.getToken();
    final userName = await _localDataSource.getUserName();

    if (token != null &&
        token.isNotEmpty &&
        userName != null &&
        userName.isNotEmpty) {
      await _remoteDataSource.logout(token, userName, null);
    }

    await _localDataSource.clear();

    // Clear the saved route on logout
    await _routePersistenceService.clearLastRoute();
  }

  @override
  Future<String?> getUserToken() => _localDataSource.getToken();

  @override
  Future<AuthEntity?> getUserData() async {
    final model = await _localDataSource.getUserData();
    return model?.toEntity();
  }

  @override
  Future<void> clearUserData() async => _localDataSource.clear();

  @override
  Future<void> saveUserData(AuthEntity user) async =>
      _localDataSource.saveAuthData(user.toDto().toModel());
}
