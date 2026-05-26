import '../entities/tariff_entity.dart';
import '../repositories/tariff_repository.dart';

/// Use case to get tariffs by vehicle ID from local database
class GetTariffsByVehicleIdUseCase {
  final TariffRepository repository;

  GetTariffsByVehicleIdUseCase(this.repository);

  Future<List<TariffEntity>> call(int vehicleId) async {
    return await repository.getTariffsByVehicleId(vehicleId);
  }
}
