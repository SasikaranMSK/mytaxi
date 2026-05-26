import 'package:flutter/foundation.dart';
import '../../../../core/clients/api_client.dart';
import '../../../../core/config/navigation_service.dart';
import '../../../../core/config/api_config.dart';
import '../dto/vehicle_dto.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleDto> getVehicle({
    required int networkId,
    required String vehicleNo,
  });
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient client;

  VehicleRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<VehicleDto> getVehicle({
    required int networkId,
    required String vehicleNo,
  }) async {
    final context = rootContext;
    if (context == null) {
      throw Exception('No BuildContext available for API call');
    }

    final result = await client.getRequest(
      ApiConfig.devicePublicVehicle,
      {
        'networkId': networkId,
        'vehicleNo': vehicleNo,
      },
      context,
    );

    if (result == null) {
      throw Exception('Failed to load vehicle');
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          debugPrint('FILTERED VEHICLE DATA => $data');
          return VehicleDto.fromJson(data);
        }
        throw Exception('Invalid vehicle response data');
      }

      if (result.containsKey('success')) {
        throw Exception(_extractErrorMessage(result, 'Failed to load vehicle'));
      }

      debugPrint('FILTERED VEHICLE DATA => ${result.toString()}');
      return VehicleDto.fromJson(result);
    }

    throw Exception('Unexpected vehicle response format');
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
