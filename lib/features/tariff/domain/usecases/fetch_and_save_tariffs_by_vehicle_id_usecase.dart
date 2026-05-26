import '../entities/tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to fetch and save tariffs by vehicle ID from remote API
class FetchAndSaveTariffsByVehicleIdUseCase {
  final TariffRepository repository;

  FetchAndSaveTariffsByVehicleIdUseCase(this.repository);

  Future<List<TariffEntity>> call(int vehicleId) async {
    return await repository.fetchAndSaveTariffsByVehicleId(vehicleId);
  }
}
