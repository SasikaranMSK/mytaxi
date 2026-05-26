import 'package:flutter/widgets.dart';
import '../../../../core/clients/api_client.dart';
import '../../../../core/config/navigation_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/auth_dto.dart';
import '../dto/login_request_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthDto?> login(LoginRequestDto request, BuildContext? context);
  Future<void> logout(String token, String userName, BuildContext? context);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthDto?> login(
    LoginRequestDto request,
    BuildContext? context,
  ) async {
    final effectiveContext = _resolveContext(context);

    final result = await client.postRequest(
      ApiConstants.loginPath,
      request.toJson(),
      effectiveContext,
    );

    if (result == null) {
      throw Exception('Login failed');
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          return AuthDto.fromJson(data);
        }
        throw Exception('Invalid login response data');
      }

      if (result.containsKey('success')) {
        throw Exception(_extractErrorMessage(result, 'Login failed'));
      }

      return AuthDto.fromJson(result);
    }

    throw Exception('Unexpected login response format');
  }

  @override
  Future<void> logout(
    String token,
    String userName,
    BuildContext? context,
  ) async {
    try {
      final effectiveContext = _resolveContext(context);

      await client.postRequest(
        ApiConstants.logoutPath,
        {"token": token, "userName": userName},
        effectiveContext,
      );
    } catch (e, stackTrace) {
      debugPrint('Logout failed unexpectedly: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  BuildContext _resolveContext(BuildContext? context) {
    final resolved = context ?? rootContext;
    if (resolved != null) return resolved;
    throw Exception('No BuildContext available for API call');
  }

  String _extractErrorMessage(Map<String, dynamic> response, String fallback) {
    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors
          .map((e) {
            if (e is String) return e;
            if (e is Map && e['message'] != null) return e['message'].toString();
            return e.toString();
          })
          .join(', ');
    }

    final message = response['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }
}
