import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<VehicleEntity> fetchAndSaveVehicle({
    required int networkId,
    required String vehicleNo,
  });
}
