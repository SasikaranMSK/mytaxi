import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';

import '../../../data/datasources/auth_local_datasource.dart';
import '../../entities/auth_entity.dart';
import '../../repositories/authentication_repository.dart';

class LoginUseCase {
  final AuthenticationRepository _repository;
  final AuthenticationLocalDataSource _localDataSource;

  LoginUseCase(this._repository, this._localDataSource);

  Future<AuthEntity?> call({
    required String username,
    required String password,
  }) async {
    final deviceId = await _getOrCreateDeviceId();

    final AuthEntity? entity = await _repository.login(
      username: username,
      password: password,
      deviceId: deviceId,
      context: null,
    );

    return entity;
  }

  Future<String> _getOrCreateDeviceId() async {
    final existing = await _localDataSource.getDeviceId();
    if (existing != null && existing.isNotEmpty) return existing;

    // On web, use browser-based device ID
    if (kIsWeb) {
      final webDeviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
      await _localDataSource.saveDeviceId(webDeviceId);
      return webDeviceId;
    }

    final info = DeviceInfoPlugin();
    String fallback =
        'generated-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

    try {
      if (io.Platform.isAndroid) {
        final android = await info.androidInfo;
        final id = android.id; // Android ID (not actual device IMEI)
        final chosen = id.isEmpty ? fallback : id;
        await _localDataSource.saveDeviceId(chosen);
        return chosen;
      }

      if (io.Platform.isIOS) {
        final ios = await info.iosInfo;
        final id = ios.identifierForVendor;
        final chosen = (id == null || id.isEmpty) ? fallback : id;
        await _localDataSource.saveDeviceId(chosen);
        return chosen;
      }

      if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
        // For desktop platforms, use a fallback
        await _localDataSource.saveDeviceId(fallback);
        return fallback;
      }
    } catch (_) {}

    await _localDataSource.saveDeviceId(fallback);
    return fallback;
  }
}
