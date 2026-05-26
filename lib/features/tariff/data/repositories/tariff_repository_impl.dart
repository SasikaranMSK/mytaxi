import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/vehicle_type_tariff_entity.dart';
import '../../domain/repositories/tariff_repository.dart';
import '../datasources/tariff_local_data_source.dart';
import '../datasources/tariff_remote_data_source.dart';
import '../mappers/tariff_mapper.dart';

/// Implementation of tariff repository
class TariffRepositoryImpl implements TariffRepository {
  final TariffLocalDataSource localDataSource;
  final TariffRemoteDataSource remoteDataSource;

  TariffRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<TariffEntity>> getAllTariffs() async {
    final dtos = await localDataSource.getAllTariffs();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<TariffEntity?> getTariffById(int id) async {
    final dto = await localDataSource.getTariffById(id);
    return dto?.toEntity();
  }

  @override
  Future<List<TariffEntity>> getActiveTariffs() async {
    final dtos = await localDataSource.getActiveTariffs();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<TariffEntity>> fetchAndSaveTariffsByVehicleId(
    int vehicleId,
  ) async {
    try {
      // Fetch from remote
      final tariffDtos = await remoteDataSource.getTarifsByVehicleId(vehicleId);

      // Convert to models
      final tariffModels = tariffDtos.map((dto) => dto.toModel()).toList();

      // Save to local database
      await localDataSource.insertTariffs(tariffModels);

      // Return entities
      return tariffModels.map((model) => model.toDto().toEntity()).toList();
    } catch (e) {
      // If remote fetch fails, return local data
      final dtos = await localDataSource.getTariffsByVehicleId(vehicleId);
      return dtos.map((dto) => dto.toEntity()).toList();
    }
  }

  @override
  Future<List<VehicleTypeTariffEntity>> fetchAndSaveTariffsByVehicleTypeId(
    int vehicleTypeId,
  ) async {
    try {
      // Fetch from remote
      final vehicleTypeTariffDtos = await remoteDataSource
          .getTarifsByVehicleTypeId(vehicleTypeId);

      // Save vehicle type tariffs
      final vehicleTypeTariffModels = vehicleTypeTariffDtos
          .map((dto) => dto.toModel())
          .toList();
      await localDataSource.insertVehicleTypeTariffs(vehicleTypeTariffModels);

      // Return entities
      return vehicleTypeTariffModels
          .map((model) => model.toDto().toEntity())
          .toList();
    } catch (e) {
      // If remote fetch fails, return local data
      final dtos = await localDataSource.getVehicleTypeTariffsByVehicleTypeId(
        vehicleTypeId,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    }
  }

  @override
  Future<List<VehicleTypeTariffEntity>> fetchAndSaveTariffsByVehicleTypeIdV2(
    int vehicleTypeId,
  ) async {
    try {
      // Fetch from remote
      final vehicleTypeTariffDtos = await remoteDataSource
          .getTarifsByVehicleTypeIdV2(vehicleTypeId);

      // Extract and save tariffs
      final tariffDtos = vehicleTypeTariffDtos
          .where((vtt) => vtt.tarif != null)
          .map((vtt) => vtt.tarif!)
          .toList();

      if (tariffDtos.isNotEmpty) {
        final tariffModels = tariffDtos.map((dto) => dto.toModel()).toList();
        await localDataSource.insertTariffs(tariffModels);
      }

      // Save vehicle type tariffs
      final vehicleTypeTariffModels = vehicleTypeTariffDtos
          .map((dto) => dto.toModel())
          .toList();
      await localDataSource.insertVehicleTypeTariffs(vehicleTypeTariffModels);

      // Return entities
      return vehicleTypeTariffModels
          .map((model) => model.toDto().toEntity())
          .toList();
    } catch (e) {
      // If remote fetch fails, return local data
      final dtos = await localDataSource.getVehicleTypeTariffsByVehicleTypeId(
        vehicleTypeId,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    }
  }

  @override
  Future<List<TariffEntity>> getTariffsByVehicleId(int vehicleId) async {
    final dtos = await localDataSource.getTariffsByVehicleId(vehicleId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<VehicleTypeTariffEntity>> getVehicleTypeTariffsByVehicleTypeId(
    int vehicleTypeId,
  ) async {
    final dtos = await localDataSource.getVehicleTypeTariffsByVehicleTypeId(
      vehicleTypeId,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> deleteAllTariffs() async {
    await localDataSource.deleteAllVehicleTypeTariffs();
    await localDataSource.deleteAllTariffs();
  }
}
