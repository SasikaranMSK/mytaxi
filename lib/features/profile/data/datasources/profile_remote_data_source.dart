import 'package:flutter/widgets.dart';
import '../../../../core/clients/api_client.dart';
import '../../../../core/config/navigation_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileDto?> getProfile(String token, BuildContext? context);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient client;

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<ProfileDto?> getProfile(String token, BuildContext? context) async {
    final effectiveContext = _resolveContext(context);
    final result = await client.getRequestWithError(
      ApiConstants.profilePath,
      null,
      effectiveContext,
    );

    if (result == null) {
      throw Exception('Failed to load profile');
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          return ProfileDto.fromJson(data);
        }
        return null;
      }

      if (result.containsKey('success')) {
        throw Exception(_extractErrorMessage(result, 'Failed to load profile'));
      }

      return ProfileDto.fromJson(result);
    }

    throw Exception('Unexpected profile response format');
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
