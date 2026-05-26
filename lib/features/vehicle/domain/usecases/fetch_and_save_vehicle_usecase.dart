import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class FetchAndSaveVehicleParams {
  final int networkId;
  final String vehicleNo;

  FetchAndSaveVehicleParams({
    required this.networkId,
    required this.vehicleNo,
  });
}

class FetchAndSaveVehicleUseCase {
  final VehicleRepository repository;

  FetchAndSaveVehicleUseCase(this.repository);

  Future<VehicleEntity> call(FetchAndSaveVehicleParams params) {
    return repository.fetchAndSaveVehicle(
      networkId: params.networkId,
      vehicleNo: params.vehicleNo,
    );
  }
}
