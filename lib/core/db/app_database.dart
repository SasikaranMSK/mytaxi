import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../../features/tariff/data/models/tariff_model.dart';
import '../../features/tariff/data/models/vehicle_type_tariff_model.dart';
import '../../features/tariff/data/dao/tariff_dao.dart';
import '../../features/tariff/data/dao/vehicle_type_tariff_dao.dart';
import '../../features/map/data/models/location_history_model.dart';
import '../../features/map/data/dao/location_history_dao.dart';
import '../../features/meter_screen/data/models/meter_trip_model.dart';
import '../../features/meter_screen/data/dao/meter_trip_dao.dart';

part 'app_database.g.dart';

/// Main application database
@Database(
  version: 3,
  entities: [
    TariffModel,
    VehicleTypeTariffModel,
    LocationHistoryModel,
    MeterTripModel,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  /// Get tariff DAO
  TariffDao get tariffDao;

  /// Get vehicle type tariff DAO
  VehicleTypeTariffDao get vehicleTypeTariffDao;

  /// Get location history DAO
  LocationHistoryDao get locationHistoryDao;

  /// Get meter trips DAO
  MeterTripDao get meterTripDao;
}
