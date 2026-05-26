import 'package:floor/floor.dart';
import '../models/vehicle_type_tariff_model.dart';

/// Data Access Object for VehicleTypeTariff
@dao
abstract class VehicleTypeTariffDao {
  /// Get all vehicle type tariffs
  @Query('SELECT * FROM vehicle_type_tariffs')
  Future<List<VehicleTypeTariffModel>> getAllVehicleTypeTariffs();

  /// Get vehicle type tariff by ID
  @Query('SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeTarifId = :id')
  Future<VehicleTypeTariffModel?> getVehicleTypeTariffById(int id);

  /// Get vehicle type tariffs by vehicle type ID
  @Query(
    'SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeId = :vehicleTypeId',
  )
  Future<List<VehicleTypeTariffModel>> getVehicleTypeTariffsByVehicleTypeId(
      int vehicleTypeId,
      );

  /// Get active vehicle type tariffs by vehicle type ID
  @Query(
    'SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeId = :vehicleTypeId AND active = 1',
  )
  Future<List<VehicleTypeTariffModel>>
  getActiveVehicleTypeTariffsByVehicleTypeId(int vehicleTypeId);

  /// Insert a vehicle type tariff
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff,
      );

  /// Insert multiple vehicle type tariffs
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertVehicleTypeTariffs(
      List<VehicleTypeTariffModel> vehicleTypeTariffs,
      );

  /// Update a vehicle type tariff
  @Update()
  Future<void> updateVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff,
      );

  /// Delete a vehicle type tariff
  @delete
  Future<void> deleteVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff,
      );

  /// Delete all vehicle type tariffs
  @Query('DELETE FROM vehicle_type_tariffs')
  Future<void> deleteAllVehicleTypeTariffs();
}
