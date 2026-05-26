import '../entities/vehicle_type_tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to get vehicle type tariffs by vehicle type ID from local database
class GetVehicleTypeTariffsByVehicleTypeIdUseCase {
  final TariffRepository repository;

  GetVehicleTypeTariffsByVehicleTypeIdUseCase(this.repository);

  Future<List<VehicleTypeTariffEntity>> call(int vehicleTypeId) async {
    return await repository.getVehicleTypeTariffsByVehicleTypeId(vehicleTypeId);
  }
}
