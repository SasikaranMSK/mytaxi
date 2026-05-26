import 'package:floor/floor.dart';
import '../models/tariff_model.dart';

/// Data Access Object for Tariff
@dao
abstract class TariffDao {
  /// Get all tariffs
  @Query('SELECT * FROM tariffs')
  Future<List<TariffModel>> getAllTariffs();

  /// Get tariff by ID
  @Query('SELECT * FROM tariffs WHERE tarifId = :id')
  Future<TariffModel?> getTariffById(int id);

  /// Get active tariffs
  @Query('SELECT * FROM tariffs WHERE active = 1')
  Future<List<TariffModel>> getActiveTariffs();

  /// Insert a tariff
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTariff(TariffModel tariff);

  /// Insert multiple tariffs
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTariffs(List<TariffModel> tariffs);

  /// Update a tariff
  @Update()
  Future<void> updateTariff(TariffModel tariff);

  /// Delete a tariff
  @delete
  Future<void> deleteTariff(TariffModel tariff);

  /// Delete all tariffs
  @Query('DELETE FROM tariffs')
  Future<void> deleteAllTariffs();

  /// Get tariffs by vehicle ID (would need a join table in a real scenario)
  @Query(
    'SELECT * FROM tariffs WHERE tarifId IN (SELECT tarifId FROM vehicle_type_tariffs WHERE vehicleTypeId = :vehicleId)',
  )
  Future<List<TariffModel>> getTariffsByVehicleId(int vehicleId);
}
