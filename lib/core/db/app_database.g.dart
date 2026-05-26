// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TariffDao? _tariffDaoInstance;

  VehicleTypeTariffDao? _vehicleTypeTariffDaoInstance;

  LocationHistoryDao? _locationHistoryDaoInstance;

  MeterTripDao? _meterTripDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `tariffs` (`tarifId` INTEGER NOT NULL, `tarifName` TEXT NOT NULL, `description` TEXT, `active` INTEGER NOT NULL, `defaultTariff` INTEGER NOT NULL, `publicHolidays` INTEGER NOT NULL, `bankHolidays` INTEGER NOT NULL, `distanceUnit` TEXT NOT NULL, `dropInterval` INTEGER NOT NULL, `flagFall` REAL NOT NULL, `flagDistance` REAL NOT NULL, `extrasIncrement` REAL NOT NULL, `distanceRate` REAL NOT NULL, `distanceRateRange` REAL NOT NULL, `distanceRate2` REAL NOT NULL, `distanceRate2Range` REAL NOT NULL, `speedThreshold` REAL NOT NULL, `timeRate` REAL NOT NULL, `journeyTimeRate` REAL NOT NULL, `waitingTimeRate` REAL NOT NULL, `timeRateSpeedThreshold` REAL NOT NULL, `returnToBoundaryDistanceDate` REAL NOT NULL, `returnToBoundaryMinimumDistance` REAL NOT NULL, `startTime` TEXT NOT NULL, `endTime` TEXT NOT NULL, `fromDay` INTEGER NOT NULL, `toDay` INTEGER NOT NULL, `secretKey` TEXT NOT NULL, PRIMARY KEY (`tarifId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vehicle_type_tariffs` (`vehicleTypeTarifId` INTEGER NOT NULL, `vehicleTypeId` INTEGER NOT NULL, `tarifId` INTEGER NOT NULL, `active` INTEGER NOT NULL, PRIMARY KEY (`vehicleTypeTarifId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LocationHistoryModel` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `lat` REAL NOT NULL, `lng` REAL NOT NULL, `timestamp` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `meter_trips` (`tripId` TEXT NOT NULL, `distance` REAL NOT NULL, `waitingTime` INTEGER NOT NULL, `totalFare` REAL NOT NULL, `startTime` INTEGER NOT NULL, `endTime` INTEGER, `tariffId` INTEGER NOT NULL, `vehicleId` INTEGER NOT NULL, PRIMARY KEY (`tripId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TariffDao get tariffDao {
    return _tariffDaoInstance ??= _$TariffDao(database, changeListener);
  }

  @override
  VehicleTypeTariffDao get vehicleTypeTariffDao {
    return _vehicleTypeTariffDaoInstance ??=
        _$VehicleTypeTariffDao(database, changeListener);
  }

  @override
  LocationHistoryDao get locationHistoryDao {
    return _locationHistoryDaoInstance ??=
        _$LocationHistoryDao(database, changeListener);
  }

  @override
  MeterTripDao get meterTripDao {
    return _meterTripDaoInstance ??= _$MeterTripDao(database, changeListener);
  }
}

class _$TariffDao extends TariffDao {
  _$TariffDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tariffModelInsertionAdapter = InsertionAdapter(
            database,
            'tariffs',
            (TariffModel item) => <String, Object?>{
                  'tarifId': item.tarifId,
                  'tarifName': item.tarifName,
                  'description': item.description,
                  'active': item.active ? 1 : 0,
                  'defaultTariff': item.defaultTariff ? 1 : 0,
                  'publicHolidays': item.publicHolidays ? 1 : 0,
                  'bankHolidays': item.bankHolidays ? 1 : 0,
                  'distanceUnit': item.distanceUnit,
                  'dropInterval': item.dropInterval,
                  'flagFall': item.flagFall,
                  'flagDistance': item.flagDistance,
                  'extrasIncrement': item.extrasIncrement,
                  'distanceRate': item.distanceRate,
                  'distanceRateRange': item.distanceRateRange,
                  'distanceRate2': item.distanceRate2,
                  'distanceRate2Range': item.distanceRate2Range,
                  'speedThreshold': item.speedThreshold,
                  'timeRate': item.timeRate,
                  'journeyTimeRate': item.journeyTimeRate,
                  'waitingTimeRate': item.waitingTimeRate,
                  'timeRateSpeedThreshold': item.timeRateSpeedThreshold,
                  'returnToBoundaryDistanceDate':
                      item.returnToBoundaryDistanceDate,
                  'returnToBoundaryMinimumDistance':
                      item.returnToBoundaryMinimumDistance,
                  'startTime': item.startTime,
                  'endTime': item.endTime,
                  'fromDay': item.fromDay,
                  'toDay': item.toDay,
                  'secretKey': item.secretKey
                }),
        _tariffModelUpdateAdapter = UpdateAdapter(
            database,
            'tariffs',
            ['tarifId'],
            (TariffModel item) => <String, Object?>{
                  'tarifId': item.tarifId,
                  'tarifName': item.tarifName,
                  'description': item.description,
                  'active': item.active ? 1 : 0,
                  'defaultTariff': item.defaultTariff ? 1 : 0,
                  'publicHolidays': item.publicHolidays ? 1 : 0,
                  'bankHolidays': item.bankHolidays ? 1 : 0,
                  'distanceUnit': item.distanceUnit,
                  'dropInterval': item.dropInterval,
                  'flagFall': item.flagFall,
                  'flagDistance': item.flagDistance,
                  'extrasIncrement': item.extrasIncrement,
                  'distanceRate': item.distanceRate,
                  'distanceRateRange': item.distanceRateRange,
                  'distanceRate2': item.distanceRate2,
                  'distanceRate2Range': item.distanceRate2Range,
                  'speedThreshold': item.speedThreshold,
                  'timeRate': item.timeRate,
                  'journeyTimeRate': item.journeyTimeRate,
                  'waitingTimeRate': item.waitingTimeRate,
                  'timeRateSpeedThreshold': item.timeRateSpeedThreshold,
                  'returnToBoundaryDistanceDate':
                      item.returnToBoundaryDistanceDate,
                  'returnToBoundaryMinimumDistance':
                      item.returnToBoundaryMinimumDistance,
                  'startTime': item.startTime,
                  'endTime': item.endTime,
                  'fromDay': item.fromDay,
                  'toDay': item.toDay,
                  'secretKey': item.secretKey
                }),
        _tariffModelDeletionAdapter = DeletionAdapter(
            database,
            'tariffs',
            ['tarifId'],
            (TariffModel item) => <String, Object?>{
                  'tarifId': item.tarifId,
                  'tarifName': item.tarifName,
                  'description': item.description,
                  'active': item.active ? 1 : 0,
                  'defaultTariff': item.defaultTariff ? 1 : 0,
                  'publicHolidays': item.publicHolidays ? 1 : 0,
                  'bankHolidays': item.bankHolidays ? 1 : 0,
                  'distanceUnit': item.distanceUnit,
                  'dropInterval': item.dropInterval,
                  'flagFall': item.flagFall,
                  'flagDistance': item.flagDistance,
                  'extrasIncrement': item.extrasIncrement,
                  'distanceRate': item.distanceRate,
                  'distanceRateRange': item.distanceRateRange,
                  'distanceRate2': item.distanceRate2,
                  'distanceRate2Range': item.distanceRate2Range,
                  'speedThreshold': item.speedThreshold,
                  'timeRate': item.timeRate,
                  'journeyTimeRate': item.journeyTimeRate,
                  'waitingTimeRate': item.waitingTimeRate,
                  'timeRateSpeedThreshold': item.timeRateSpeedThreshold,
                  'returnToBoundaryDistanceDate':
                      item.returnToBoundaryDistanceDate,
                  'returnToBoundaryMinimumDistance':
                      item.returnToBoundaryMinimumDistance,
                  'startTime': item.startTime,
                  'endTime': item.endTime,
                  'fromDay': item.fromDay,
                  'toDay': item.toDay,
                  'secretKey': item.secretKey
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TariffModel> _tariffModelInsertionAdapter;

  final UpdateAdapter<TariffModel> _tariffModelUpdateAdapter;

  final DeletionAdapter<TariffModel> _tariffModelDeletionAdapter;

  @override
  Future<List<TariffModel>> getAllTariffs() async {
    return _queryAdapter.queryList('SELECT * FROM tariffs',
        mapper: (Map<String, Object?> row) => TariffModel(
            tarifId: row['tarifId'] as int,
            tarifName: row['tarifName'] as String,
            description: row['description'] as String?,
            active: (row['active'] as int) != 0,
            defaultTariff: (row['defaultTariff'] as int) != 0,
            publicHolidays: (row['publicHolidays'] as int) != 0,
            bankHolidays: (row['bankHolidays'] as int) != 0,
            distanceUnit: row['distanceUnit'] as String,
            dropInterval: row['dropInterval'] as int,
            flagFall: row['flagFall'] as double,
            flagDistance: row['flagDistance'] as double,
            extrasIncrement: row['extrasIncrement'] as double,
            distanceRate: row['distanceRate'] as double,
            distanceRateRange: row['distanceRateRange'] as double,
            distanceRate2: row['distanceRate2'] as double,
            distanceRate2Range: row['distanceRate2Range'] as double,
            speedThreshold: row['speedThreshold'] as double,
            timeRate: row['timeRate'] as double,
            journeyTimeRate: row['journeyTimeRate'] as double,
            waitingTimeRate: row['waitingTimeRate'] as double,
            timeRateSpeedThreshold: row['timeRateSpeedThreshold'] as double,
            returnToBoundaryDistanceDate:
                row['returnToBoundaryDistanceDate'] as double,
            returnToBoundaryMinimumDistance:
                row['returnToBoundaryMinimumDistance'] as double,
            startTime: row['startTime'] as String,
            endTime: row['endTime'] as String,
            fromDay: row['fromDay'] as int,
            toDay: row['toDay'] as int,
            secretKey: row['secretKey'] as String));
  }

  @override
  Future<TariffModel?> getTariffById(int id) async {
    return _queryAdapter.query('SELECT * FROM tariffs WHERE tarifId = ?1',
        mapper: (Map<String, Object?> row) => TariffModel(
            tarifId: row['tarifId'] as int,
            tarifName: row['tarifName'] as String,
            description: row['description'] as String?,
            active: (row['active'] as int) != 0,
            defaultTariff: (row['defaultTariff'] as int) != 0,
            publicHolidays: (row['publicHolidays'] as int) != 0,
            bankHolidays: (row['bankHolidays'] as int) != 0,
            distanceUnit: row['distanceUnit'] as String,
            dropInterval: row['dropInterval'] as int,
            flagFall: row['flagFall'] as double,
            flagDistance: row['flagDistance'] as double,
            extrasIncrement: row['extrasIncrement'] as double,
            distanceRate: row['distanceRate'] as double,
            distanceRateRange: row['distanceRateRange'] as double,
            distanceRate2: row['distanceRate2'] as double,
            distanceRate2Range: row['distanceRate2Range'] as double,
            speedThreshold: row['speedThreshold'] as double,
            timeRate: row['timeRate'] as double,
            journeyTimeRate: row['journeyTimeRate'] as double,
            waitingTimeRate: row['waitingTimeRate'] as double,
            timeRateSpeedThreshold: row['timeRateSpeedThreshold'] as double,
            returnToBoundaryDistanceDate:
                row['returnToBoundaryDistanceDate'] as double,
            returnToBoundaryMinimumDistance:
                row['returnToBoundaryMinimumDistance'] as double,
            startTime: row['startTime'] as String,
            endTime: row['endTime'] as String,
            fromDay: row['fromDay'] as int,
            toDay: row['toDay'] as int,
            secretKey: row['secretKey'] as String),
        arguments: [id]);
  }

  @override
  Future<List<TariffModel>> getActiveTariffs() async {
    return _queryAdapter.queryList('SELECT * FROM tariffs WHERE active = 1',
        mapper: (Map<String, Object?> row) => TariffModel(
            tarifId: row['tarifId'] as int,
            tarifName: row['tarifName'] as String,
            description: row['description'] as String?,
            active: (row['active'] as int) != 0,
            defaultTariff: (row['defaultTariff'] as int) != 0,
            publicHolidays: (row['publicHolidays'] as int) != 0,
            bankHolidays: (row['bankHolidays'] as int) != 0,
            distanceUnit: row['distanceUnit'] as String,
            dropInterval: row['dropInterval'] as int,
            flagFall: row['flagFall'] as double,
            flagDistance: row['flagDistance'] as double,
            extrasIncrement: row['extrasIncrement'] as double,
            distanceRate: row['distanceRate'] as double,
            distanceRateRange: row['distanceRateRange'] as double,
            distanceRate2: row['distanceRate2'] as double,
            distanceRate2Range: row['distanceRate2Range'] as double,
            speedThreshold: row['speedThreshold'] as double,
            timeRate: row['timeRate'] as double,
            journeyTimeRate: row['journeyTimeRate'] as double,
            waitingTimeRate: row['waitingTimeRate'] as double,
            timeRateSpeedThreshold: row['timeRateSpeedThreshold'] as double,
            returnToBoundaryDistanceDate:
                row['returnToBoundaryDistanceDate'] as double,
            returnToBoundaryMinimumDistance:
                row['returnToBoundaryMinimumDistance'] as double,
            startTime: row['startTime'] as String,
            endTime: row['endTime'] as String,
            fromDay: row['fromDay'] as int,
            toDay: row['toDay'] as int,
            secretKey: row['secretKey'] as String));
  }

  @override
  Future<void> deleteAllTariffs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM tariffs');
  }

  @override
  Future<List<TariffModel>> getTariffsByVehicleId(int vehicleId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM tariffs WHERE tarifId IN (SELECT tarifId FROM vehicle_type_tariffs WHERE vehicleTypeId = ?1)',
        mapper: (Map<String, Object?> row) => TariffModel(tarifId: row['tarifId'] as int, tarifName: row['tarifName'] as String, description: row['description'] as String?, active: (row['active'] as int) != 0, defaultTariff: (row['defaultTariff'] as int) != 0, publicHolidays: (row['publicHolidays'] as int) != 0, bankHolidays: (row['bankHolidays'] as int) != 0, distanceUnit: row['distanceUnit'] as String, dropInterval: row['dropInterval'] as int, flagFall: row['flagFall'] as double, flagDistance: row['flagDistance'] as double, extrasIncrement: row['extrasIncrement'] as double, distanceRate: row['distanceRate'] as double, distanceRateRange: row['distanceRateRange'] as double, distanceRate2: row['distanceRate2'] as double, distanceRate2Range: row['distanceRate2Range'] as double, speedThreshold: row['speedThreshold'] as double, timeRate: row['timeRate'] as double, journeyTimeRate: row['journeyTimeRate'] as double, waitingTimeRate: row['waitingTimeRate'] as double, timeRateSpeedThreshold: row['timeRateSpeedThreshold'] as double, returnToBoundaryDistanceDate: row['returnToBoundaryDistanceDate'] as double, returnToBoundaryMinimumDistance: row['returnToBoundaryMinimumDistance'] as double, startTime: row['startTime'] as String, endTime: row['endTime'] as String, fromDay: row['fromDay'] as int, toDay: row['toDay'] as int, secretKey: row['secretKey'] as String),
        arguments: [vehicleId]);
  }

  @override
  Future<void> insertTariff(TariffModel tariff) async {
    await _tariffModelInsertionAdapter.insert(
        tariff, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertTariffs(List<TariffModel> tariffs) async {
    await _tariffModelInsertionAdapter.insertList(
        tariffs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateTariff(TariffModel tariff) async {
    await _tariffModelUpdateAdapter.update(tariff, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTariff(TariffModel tariff) async {
    await _tariffModelDeletionAdapter.delete(tariff);
  }
}

class _$VehicleTypeTariffDao extends VehicleTypeTariffDao {
  _$VehicleTypeTariffDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _vehicleTypeTariffModelInsertionAdapter = InsertionAdapter(
            database,
            'vehicle_type_tariffs',
            (VehicleTypeTariffModel item) => <String, Object?>{
                  'vehicleTypeTarifId': item.vehicleTypeTarifId,
                  'vehicleTypeId': item.vehicleTypeId,
                  'tarifId': item.tarifId,
                  'active': item.active ? 1 : 0
                }),
        _vehicleTypeTariffModelUpdateAdapter = UpdateAdapter(
            database,
            'vehicle_type_tariffs',
            ['vehicleTypeTarifId'],
            (VehicleTypeTariffModel item) => <String, Object?>{
                  'vehicleTypeTarifId': item.vehicleTypeTarifId,
                  'vehicleTypeId': item.vehicleTypeId,
                  'tarifId': item.tarifId,
                  'active': item.active ? 1 : 0
                }),
        _vehicleTypeTariffModelDeletionAdapter = DeletionAdapter(
            database,
            'vehicle_type_tariffs',
            ['vehicleTypeTarifId'],
            (VehicleTypeTariffModel item) => <String, Object?>{
                  'vehicleTypeTarifId': item.vehicleTypeTarifId,
                  'vehicleTypeId': item.vehicleTypeId,
                  'tarifId': item.tarifId,
                  'active': item.active ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<VehicleTypeTariffModel>
      _vehicleTypeTariffModelInsertionAdapter;

  final UpdateAdapter<VehicleTypeTariffModel>
      _vehicleTypeTariffModelUpdateAdapter;

  final DeletionAdapter<VehicleTypeTariffModel>
      _vehicleTypeTariffModelDeletionAdapter;

  @override
  Future<List<VehicleTypeTariffModel>> getAllVehicleTypeTariffs() async {
    return _queryAdapter.queryList('SELECT * FROM vehicle_type_tariffs',
        mapper: (Map<String, Object?> row) => VehicleTypeTariffModel(
            vehicleTypeTarifId: row['vehicleTypeTarifId'] as int,
            vehicleTypeId: row['vehicleTypeId'] as int,
            tarifId: row['tarifId'] as int,
            active: (row['active'] as int) != 0));
  }

  @override
  Future<VehicleTypeTariffModel?> getVehicleTypeTariffById(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeTarifId = ?1',
        mapper: (Map<String, Object?> row) => VehicleTypeTariffModel(
            vehicleTypeTarifId: row['vehicleTypeTarifId'] as int,
            vehicleTypeId: row['vehicleTypeId'] as int,
            tarifId: row['tarifId'] as int,
            active: (row['active'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<VehicleTypeTariffModel>> getVehicleTypeTariffsByVehicleTypeId(
      int vehicleTypeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeId = ?1',
        mapper: (Map<String, Object?> row) => VehicleTypeTariffModel(
            vehicleTypeTarifId: row['vehicleTypeTarifId'] as int,
            vehicleTypeId: row['vehicleTypeId'] as int,
            tarifId: row['tarifId'] as int,
            active: (row['active'] as int) != 0),
        arguments: [vehicleTypeId]);
  }

  @override
  Future<List<VehicleTypeTariffModel>>
      getActiveVehicleTypeTariffsByVehicleTypeId(int vehicleTypeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vehicle_type_tariffs WHERE vehicleTypeId = ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => VehicleTypeTariffModel(vehicleTypeTarifId: row['vehicleTypeTarifId'] as int, vehicleTypeId: row['vehicleTypeId'] as int, tarifId: row['tarifId'] as int, active: (row['active'] as int) != 0),
        arguments: [vehicleTypeId]);
  }

  @override
  Future<void> deleteAllVehicleTypeTariffs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM vehicle_type_tariffs');
  }

  @override
  Future<void> insertVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff) async {
    await _vehicleTypeTariffModelInsertionAdapter.insert(
        vehicleTypeTariff, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertVehicleTypeTariffs(
      List<VehicleTypeTariffModel> vehicleTypeTariffs) async {
    await _vehicleTypeTariffModelInsertionAdapter.insertList(
        vehicleTypeTariffs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff) async {
    await _vehicleTypeTariffModelUpdateAdapter.update(
        vehicleTypeTariff, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVehicleTypeTariff(
      VehicleTypeTariffModel vehicleTypeTariff) async {
    await _vehicleTypeTariffModelDeletionAdapter.delete(vehicleTypeTariff);
  }
}

class _$LocationHistoryDao extends LocationHistoryDao {
  _$LocationHistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _locationHistoryModelInsertionAdapter = InsertionAdapter(
            database,
            'LocationHistoryModel',
            (LocationHistoryModel item) => <String, Object?>{
                  'id': item.id,
                  'lat': item.lat,
                  'lng': item.lng,
                  'timestamp': item.timestamp
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LocationHistoryModel>
      _locationHistoryModelInsertionAdapter;

  @override
  Future<List<LocationHistoryModel>> getAllLocationHistory() async {
    return _queryAdapter.queryList(
        'SELECT * FROM LocationHistoryModel ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => LocationHistoryModel(
            id: row['id'] as int?,
            lat: row['lat'] as double,
            lng: row['lng'] as double,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<List<LocationHistoryModel>> getLocationHistorySince(
      int timestamp) async {
    return _queryAdapter.queryList(
        'SELECT * FROM LocationHistoryModel WHERE timestamp > ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => LocationHistoryModel(id: row['id'] as int?, lat: row['lat'] as double, lng: row['lng'] as double, timestamp: row['timestamp'] as int),
        arguments: [timestamp]);
  }

  @override
  Future<void> deleteOlderThan(int timestamp) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM LocationHistoryModel WHERE timestamp < ?1',
        arguments: [timestamp]);
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM LocationHistoryModel');
  }

  @override
  Future<int?> getCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM LocationHistoryModel',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertLocationHistory(LocationHistoryModel locationHistory) {
    return _locationHistoryModelInsertionAdapter.insertAndReturnId(
        locationHistory, OnConflictStrategy.abort);
  }
}

class _$MeterTripDao extends MeterTripDao {
  _$MeterTripDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _meterTripModelInsertionAdapter = InsertionAdapter(
            database,
            'meter_trips',
            (MeterTripModel item) => <String, Object?>{
                  'tripId': item.tripId,
                  'distance': item.distance,
                  'waitingTime': item.waitingTime,
                  'totalFare': item.totalFare,
                  'startTime': item.startTime,
                  'endTime': item.endTime,
                  'tariffId': item.tariffId,
                  'vehicleId': item.vehicleId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MeterTripModel> _meterTripModelInsertionAdapter;

  @override
  Future<List<MeterTripModel>> getAllTrips() async {
    return _queryAdapter.queryList(
        'SELECT * FROM meter_trips ORDER BY startTime DESC',
        mapper: (Map<String, Object?> row) => MeterTripModel(
            tripId: row['tripId'] as String,
            distance: row['distance'] as double,
            waitingTime: row['waitingTime'] as int,
            totalFare: row['totalFare'] as double,
            startTime: row['startTime'] as int,
            endTime: row['endTime'] as int?,
            tariffId: row['tariffId'] as int,
            vehicleId: row['vehicleId'] as int));
  }

  @override
  Future<void> clear() async {
    await _queryAdapter.queryNoReturn('DELETE FROM meter_trips');
  }

  @override
  Future<void> insertTrip(MeterTripModel trip) async {
    await _meterTripModelInsertionAdapter.insert(
        trip, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertTrips(List<MeterTripModel> trips) async {
    await _meterTripModelInsertionAdapter.insertList(
        trips, OnConflictStrategy.replace);
  }
}
