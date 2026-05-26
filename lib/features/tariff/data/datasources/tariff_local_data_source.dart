import '../dto/tariff_dto.dart';
import '../dto/vehicle_type_tariff_dto.dart';
import '../mappers/tariff_mapper.dart';
import '../models/tariff_model.dart';
import '../models/vehicle_type_tariff_model.dart';
import '../dao/tariff_dao.dart';
import '../dao/vehicle_type_tariff_dao.dart';

/// Abstract class for local data source
abstract class TariffLocalDataSource {
  Future<List<TariffDto>> getAllTariffs();
  Future<TariffDto?> getTariffById(int id);
  Future<List<TariffDto>> getActiveTariffs();
  Future<void> insertTariff(TariffModel tariff);
  Future<void> insertTariffs(List<TariffModel> tariffs);
  Future<void> updateTariff(TariffModel tariff);
  Future<void> deleteTariff(TariffModel tariff);
  Future<void> deleteAllTariffs();
  Future<List<TariffDto>> getTariffsByVehicleId(int vehicleId);
  Future<List<VehicleTypeTariffDto>> getVehicleTypeTariffsByVehicleTypeId(
    int vehicleTypeId,
  );
  Future<void> insertVehicleTypeTariffs(
    List<VehicleTypeTariffModel> vehicleTypeTariffs,
  );
  Future<void> deleteAllVehicleTypeTariffs();
}

/// Implementation of local data source
class TariffLocalDataSourceImpl implements TariffLocalDataSource {
  final TariffDao tariffDao;
  final VehicleTypeTariffDao vehicleTypeTariffDao;

  TariffLocalDataSourceImpl({
    required this.tariffDao,
    required this.vehicleTypeTariffDao,
  });

  @override
  Future<List<TariffDto>> getAllTariffs() async {
    final tariffs = await tariffDao.getAllTariffs();
    return tariffs.map((tariff) => tariff.toDto()).toList();
  }

  @override
  Future<TariffDto?> getTariffById(int id) async {
    final tariff = await tariffDao.getTariffById(id);
    return tariff?.toDto();
  }

  @override
  Future<List<TariffDto>> getActiveTariffs() async {
    final tariffs = await tariffDao.getActiveTariffs();
    return tariffs.map((tariff) => tariff.toDto()).toList();
  }

  @override
  Future<void> insertTariff(TariffModel tariff) async {
    await tariffDao.insertTariff(tariff);
  }

  @override
  Future<void> insertTariffs(List<TariffModel> tariffs) async {
    await tariffDao.insertTariffs(tariffs);
  }

  @override
  Future<void> updateTariff(TariffModel tariff) async {
    await tariffDao.updateTariff(tariff);
  }

  @override
  Future<void> deleteTariff(TariffModel tariff) async {
    await tariffDao.deleteTariff(tariff);
  }

  @override
  Future<void> deleteAllTariffs() async {
    await tariffDao.deleteAllTariffs();
  }

  @override
  Future<List<TariffDto>> getTariffsByVehicleId(int vehicleId) async {
    final tariffs = await tariffDao.getTariffsByVehicleId(vehicleId);
    return tariffs.map((tariff) => tariff.toDto()).toList();
  }

  @override
  Future<List<VehicleTypeTariffDto>> getVehicleTypeTariffsByVehicleTypeId(
    int vehicleTypeId,
  ) async {
    final vehicleTypeTariffs = await vehicleTypeTariffDao
        .getVehicleTypeTariffsByVehicleTypeId(vehicleTypeId);

    // Join with tariff data for each vehicle type tariff
    final result = <VehicleTypeTariffDto>[];
    for (final vtt in vehicleTypeTariffs) {
      final tariff = await tariffDao.getTariffById(vtt.tarifId);
      result.add(
        vtt.toDto(tariff: tariff?.toDto()),
      );
    }
    return result;
  }

  @override
  Future<void> insertVehicleTypeTariffs(
    List<VehicleTypeTariffModel> vehicleTypeTariffs,
  ) async {
    await vehicleTypeTariffDao.insertVehicleTypeTariffs(vehicleTypeTariffs);
  }

  @override
  Future<void> deleteAllVehicleTypeTariffs() async {
    await vehicleTypeTariffDao.deleteAllVehicleTypeTariffs();
  }
}

class TariffLocalDataSourceMemory implements TariffLocalDataSource {
  final List<TariffModel> _tariffs = [];
  final List<VehicleTypeTariffModel> _vehicleTypeTariffs = [];

  @override
  Future<List<TariffDto>> getAllTariffs() async {
    return _tariffs.map((tariff) => tariff.toDto()).toList();
  }

  @override
  Future<TariffDto?> getTariffById(int id) async {
    final index = _tariffs.indexWhere((tariff) => tariff.tarifId == id);
    if (index == -1) {
      return null;
    }
    return _tariffs[index].toDto();
  }

  @override
  Future<List<TariffDto>> getActiveTariffs() async {
    return _tariffs
        .where((tariff) => tariff.active)
        .map((tariff) => tariff.toDto())
        .toList();
  }

  @override
  Future<void> insertTariff(TariffModel tariff) async {
    final index = _tariffs.indexWhere((item) => item.tarifId == tariff.tarifId);
    if (index == -1) {
      _tariffs.add(tariff);
    } else {
      _tariffs[index] = tariff;
    }
  }

  @override
  Future<void> insertTariffs(List<TariffModel> tariffs) async {
    for (final tariff in tariffs) {
      await insertTariff(tariff);
    }
  }

  @override
  Future<void> updateTariff(TariffModel tariff) async {
    await insertTariff(tariff);
  }

  @override
  Future<void> deleteTariff(TariffModel tariff) async {
    _tariffs.removeWhere((item) => item.tarifId == tariff.tarifId);
  }

  @override
  Future<void> deleteAllTariffs() async {
    _tariffs.clear();
  }

  @override
  Future<List<TariffDto>> getTariffsByVehicleId(int vehicleId) async {
    return _tariffs.map((tariff) => tariff.toDto()).toList();
  }

  @override
  Future<List<VehicleTypeTariffDto>> getVehicleTypeTariffsByVehicleTypeId(
    int vehicleTypeId,
  ) async {
    final filteredVtt = _vehicleTypeTariffs
        .where((vtt) => vtt.vehicleTypeId == vehicleTypeId)
        .toList();

    // Join with tariff data
    final result = <VehicleTypeTariffDto>[];
    for (final vtt in filteredVtt) {
      final tariffModel = _tariffs
          .where((t) => t.tarifId == vtt.tarifId)
          .firstOrNull;
      result.add(
        vtt.toDto(tariff: tariffModel?.toDto()),
      );
    }
    return result;
  }

  @override
  Future<void> insertVehicleTypeTariffs(
    List<VehicleTypeTariffModel> vehicleTypeTariffs,
  ) async {
    for (final vtt in vehicleTypeTariffs) {
      final index = _vehicleTypeTariffs.indexWhere(
        (item) => item.vehicleTypeTarifId == vtt.vehicleTypeTarifId,
      );
      if (index == -1) {
        _vehicleTypeTariffs.add(vtt);
      } else {
        _vehicleTypeTariffs[index] = vtt;
      }
    }
  }

  @override
  Future<void> deleteAllVehicleTypeTariffs() async {
    _vehicleTypeTariffs.clear();
  }
}
