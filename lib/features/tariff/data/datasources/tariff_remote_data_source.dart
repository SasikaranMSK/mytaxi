import '../../../../core/clients/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/tariff_dto.dart';
import '../dto/vehicle_type_tariff_dto.dart';

/// Abstract class for remote data source
abstract class TariffRemoteDataSource {
  Future<List<TariffDto>> getTarifsByVehicleId(int vehicleId);
  Future<List<VehicleTypeTariffDto>> getTarifsByVehicleTypeId(
    int vehicleTypeId,
  );
  Future<List<VehicleTypeTariffDto>> getTarifsByVehicleTypeIdV2(
    int vehicleTypeId,
  );
}

/// Implementation of remote data source
class TariffRemoteDataSourceImpl implements TariffRemoteDataSource {
  final ApiClient client;

  TariffRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TariffDto>> getTarifsByVehicleId(int vehicleId) async {
    final result = await client.getRequest(
      ApiConstants.getTariffsByVehicleIdPath(vehicleId),
      null,
      null,
    );

    if (result == null) {
      return [];
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          return data
              .map((item) => TariffDto.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      if (result.containsKey('success')) {
        throw Exception(_extractErrorMessage(result, 'Failed to load tariffs'));
      }
    }

    if (result is List) {
      return result
          .map((item) => TariffDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<List<VehicleTypeTariffDto>> getTarifsByVehicleTypeId(
    int vehicleTypeId,
  ) async {
    final result = await client.getRequest(
      ApiConstants.getTariffsByVehicleTypeIdPath(vehicleTypeId),
      null,
      null,
    );

    if (result == null) {
      return [];
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          return data
              .map(
                (item) =>
                    VehicleTypeTariffDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      }

      if (result.containsKey('success')) {
        throw Exception(
          _extractErrorMessage(result, 'Failed to load vehicle type tariffs'),
        );
      }
    }

    if (result is List) {
      return result
          .map(
            (item) =>
                VehicleTypeTariffDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  @override
  Future<List<VehicleTypeTariffDto>> getTarifsByVehicleTypeIdV2(
    int vehicleTypeId,
  ) async {
    final result = await client.getRequest(
      ApiConstants.getTariffsByVehicleTypeIdV2Path(vehicleTypeId),
      null,
      null,
    );

    if (result == null) {
      return [];
    }

    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          return data
              .map(
                (item) =>
                    VehicleTypeTariffDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      }

      if (result.containsKey('success')) {
        throw Exception(
          _extractErrorMessage(
            result,
            'Failed to load vehicle type tariffs v2',
          ),
        );
      }
    }

    if (result is List) {
      return result
          .map(
            (item) =>
                VehicleTypeTariffDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  String _extractErrorMessage(Map<String, dynamic> response, String fallback) {
    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors
          .map((e) {
            if (e is String) return e;
            if (e is Map && e['message'] != null) {
              return e['message'].toString();
            }
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
