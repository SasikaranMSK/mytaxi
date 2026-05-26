import '../entities/vehicle_type_tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to fetch and save tariffs by vehicle type ID from remote API (v2)
class FetchAndSaveTariffsByVehicleTypeIdV2UseCase {
  final TariffRepository repository;

  FetchAndSaveTariffsByVehicleTypeIdV2UseCase(this.repository);

  Future<List<VehicleTypeTariffEntity>> call(int vehicleTypeId) async {
    return await repository.fetchAndSaveTariffsByVehicleTypeIdV2(vehicleTypeId);
  }
}
