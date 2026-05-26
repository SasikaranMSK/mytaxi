import '../entities/tariff_entity.dart';
import '../entities/vehicle_type_tariff_entity.dart';

/// Abstract repository for tariff operations
abstract class TariffRepository {
  /// Get all tariffs from local database
  Future<List<TariffEntity>> getAllTariffs();

  /// Get tariff by ID from local database
  Future<TariffEntity?> getTariffById(int id);

  /// Get active tariffs from local database
  Future<List<TariffEntity>> getActiveTariffs();

  /// Fetch and save tariffs by vehicle ID from remote API
  Future<List<TariffEntity>> fetchAndSaveTariffsByVehicleId(int vehicleId);

  /// Fetch and save tariffs by vehicle type ID from remote API
  Future<List<VehicleTypeTariffEntity>> fetchAndSaveTariffsByVehicleTypeId(
      int vehicleTypeId,
      );

  /// Fetch and save tariffs by vehicle type ID from remote API (v2)
  Future<List<VehicleTypeTariffEntity>> fetchAndSaveTariffsByVehicleTypeIdV2(
      int vehicleTypeId,
      );

  /// Get tariffs by vehicle ID from local database
  Future<List<TariffEntity>> getTariffsByVehicleId(int vehicleId);

  /// Get vehicle type tariffs by vehicle type ID from local database
  Future<List<VehicleTypeTariffEntity>> getVehicleTypeTariffsByVehicleTypeId(
      int vehicleTypeId,
      );

  /// Delete all tariffs from local database
  Future<void> deleteAllTariffs();
}
