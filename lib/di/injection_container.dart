import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:floor/floor.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../core/db/app_database.dart';
import '../core/clients/api_client.dart';
import '../core/storage/token_storage.dart';
import '../core/services/route_persistence_service.dart';

// ============ AUTH ============
import '../features/authentication/auth_injection.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';

// ============ PROFILE ============
import '../features/profile/profile_injection.dart';

// ============ DASHBOARD ============
import '../features/dashboard/dashboard_injection.dart';

// ============ VEHICLE ============
import '../core/storage/vehicle_storage.dart';
import '../features/vehicle/data/datasources/vehicle_local_data_source.dart';
import '../features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import '../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../features/vehicle/domain/repositories/vehicle_repository.dart';
import '../features/vehicle/presentation/bloc/vehicle_bloc.dart';

// ============ TARIFF ============
import '../features/tariff/data/datasources/tariff_local_data_source.dart';
import '../features/tariff/data/datasources/tariff_remote_data_source.dart';
import '../features/tariff/data/repositories/tariff_repository_impl.dart';
import '../features/tariff/domain/repositories/tariff_repository.dart';
import '../features/tariff/domain/usecases/get_all_tariffs_usecase.dart';
import '../features/tariff/domain/usecases/get_tariff_by_id_usecase.dart';
import '../features/tariff/domain/usecases/get_active_tariffs_usecase.dart';
import '../features/tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_id_usecase.dart';
import '../features/tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_type_id_usecase.dart';
import '../features/tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_type_id_v2_usecase.dart';
import '../features/tariff/domain/usecases/get_tariffs_by_vehicle_id_usecase.dart';
import '../features/tariff/domain/usecases/get_vehicle_type_tariffs_by_vehicle_type_id_usecase.dart';

// ============ METER ============
import '../features/meter_screen/data/datasources/meter_local_datasource.dart';
import '../features/meter_screen/data/datasources/meter_remote_data_source.dart';
import '../features/meter_screen/data/repositories/meter_repository_impl.dart';
import 'package:meter_taxi/features/meter_screen/data/repositories/meter_repo_floor.dart';
import '../features/meter_screen/domain/repositories/meter_repository.dart';
import '../features/meter_screen/domain/usecases/calculate_fare.dart';
import '../features/meter_screen/domain/usecases/start_meter.dart';
import '../features/meter_screen/domain/usecases/stop_meter.dart';
import '../features/vehicle/domain/usecases/fetch_and_save_vehicle_usecase.dart';

// ============ MAP ============
import '../features/map/data/datasources/location_datasource.dart';
import '../features/map/data/datasources/location_history_datasource.dart';
import '../features/map/data/repositories/location_history_repository_impl.dart';
import '../features/map/domain/repositories/location_history_repository.dart';
import '../features/map/domain/entities/location_history_entity.dart';
import '../features/map/domain/usecases/store_location_history_usecase.dart';
import '../features/map/presentation/bloc/map_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // ================= DATABASE =================
  // Skip for web temporarily
  if (!kIsWeb) {
    final database = await $FloorAppDatabase
        .databaseBuilder('taxi_database.db')
        .addMigrations([
          Migration(1, 2, (db) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS `LocationHistoryModel` ('
              '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
              '`lat` REAL NOT NULL, '
              '`lng` REAL NOT NULL, '
              '`timestamp` INTEGER NOT NULL)',
            );
          }),
          Migration(2, 3, (db) async {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS `meter_trips` ('
              '`tripId` TEXT PRIMARY KEY, '
              '`distance` REAL NOT NULL, '
              '`waitingTime` INTEGER NOT NULL, '
              '`totalFare` REAL NOT NULL, '
              '`startTime` INTEGER NOT NULL, '
              '`endTime` INTEGER, '
              '`tariffId` INTEGER NOT NULL, '
              '`vehicleId` INTEGER NOT NULL)',
            );
          }),
        ])
        .build();
    sl.registerSingleton<AppDatabase>(database);
  }

  // ================= SHARED PREFS =================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ================= ROUTE PERSISTENCE =================
  sl.registerLazySingleton<RoutePersistenceService>(
    () => RoutePersistenceService(sl<SharedPreferences>()),
  );

  // ================= STORAGE =================
  if (!kIsWeb) {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }

  sl.registerLazySingleton<TokenStorage>(
    () => TokenStorage(
      kIsWeb ? null : sl<FlutterSecureStorage>(),
      sl<SharedPreferences>(),
    ),
  );

  // ================= DIO =================
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept any status code to handle it in the response
        return status != null && status < 500;
      },
      followRedirects: true,
      maxRedirects: 5,
    ),
  );

  // Bearer token interceptor (token stored via TokenStorage)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sl<TokenStorage>().getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  sl.registerLazySingleton<Dio>(() => dio);

  // Core API client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<TokenStorage>()));

  // =========================================================
  // ======================= VEHICLE ==========================
  // =========================================================

  sl.registerLazySingleton<VehicleStorage>(
    () => VehicleStorage(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<VehicleLocalDataSource>(
    () => VehicleLocalDataSourceImpl(storage: sl<VehicleStorage>()),
  );

  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(client: sl<ApiClient>()),
  );

  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remote: sl(), local: sl()),
  );

  sl.registerLazySingleton(() => FetchAndSaveVehicleUseCase(sl()));
  sl.registerFactory<VehicleBloc>(() => VehicleBloc(sl(), sl()));

  // =========================================================
  // ======================== TARIFF ==========================
  // =========================================================

  if (!kIsWeb) {
    sl.registerLazySingleton<TariffLocalDataSource>(
      () => TariffLocalDataSourceImpl(
        tariffDao: sl<AppDatabase>().tariffDao,
        vehicleTypeTariffDao: sl<AppDatabase>().vehicleTypeTariffDao,
      ),
    );
  } else {
    sl.registerLazySingleton<TariffLocalDataSource>(
      () => TariffLocalDataSourceMemory(),
    );
  }

  sl.registerLazySingleton<TariffRemoteDataSource>(
    () => TariffRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<TariffRepository>(
    () => TariffRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // No external notification plugin registered (using foreground notification updates)

  sl.registerLazySingleton(() => GetAllTariffsUseCase(sl()));
  sl.registerLazySingleton(() => GetTariffByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveTariffsUseCase(sl()));
  sl.registerLazySingleton(() => FetchAndSaveTariffsByVehicleIdUseCase(sl()));
  sl.registerLazySingleton(
    () => FetchAndSaveTariffsByVehicleTypeIdUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => FetchAndSaveTariffsByVehicleTypeIdV2UseCase(sl()),
  );
  sl.registerLazySingleton(() => GetTariffsByVehicleIdUseCase(sl()));
  sl.registerLazySingleton(
    () => GetVehicleTypeTariffsByVehicleTypeIdUseCase(sl()),
  );

  // =========================================================
  // ========================= METER ==========================
  // =========================================================

  // Usecases (pure)
  sl.registerLazySingleton(() => StartMeter());
  sl.registerLazySingleton(() => StopMeter());
  sl.registerLazySingleton(() => CalculateFare());

  // Local datasource (SharedPreferences works on web + mobile)
  sl.registerLazySingleton<MeterLocalDataSource>(
    () => MeterLocalDataSource(sl<SharedPreferences>()),
  );

  // Remote datasource uses ApiClient
  sl.registerLazySingleton<MeterRemoteDataSource>(
    () => MeterRemoteDataSourceImpl(client: sl<ApiClient>()),
  );

  // Repository (use Floor on mobile, fallback for web)
  if (!kIsWeb) {
    sl.registerLazySingleton<MeterRepository>(
      () => MeterRepositoryFloor(dao: sl<AppDatabase>().meterTripDao),
    );
  } else {
    sl.registerLazySingleton<MeterRepository>(
      () => MeterRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
    );
  }

  // =========================================================
  // =========================== MAP ==========================
  // =========================================================
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSource());

  if (!kIsWeb) {
    sl.registerLazySingleton<LocationHistoryDataSource>(
      () => LocationHistoryDataSource(sl<AppDatabase>().locationHistoryDao),
    );
    sl.registerLazySingleton<LocationHistoryRepository>(
      () => LocationHistoryRepositoryImpl(sl<LocationHistoryDataSource>()),
    );
    sl.registerLazySingleton<StoreLocationHistoryUseCase>(
      () => StoreLocationHistoryUseCase(sl<LocationHistoryRepository>()),
    );

    sl.registerFactory<MapBloc>(
      () => MapBloc(
        ds: sl<LocationDataSource>(),
        storeLocationHistoryUseCase: sl<StoreLocationHistoryUseCase>(),
      ),
    );
  } else {
    sl.registerFactory<MapBloc>(
      () => MapBloc(
        ds: sl<LocationDataSource>(),
        storeLocationHistoryUseCase: StoreLocationHistoryUseCase(
          _DummyLocationHistoryRepository(),
        ),
      ),
    );
  }

  // =========================================================
  // ========================== AUTH ==========================
  // =========================================================

  // Authentication module from auth_injection.dart
  authenticationModule(sl);

  // Auth Bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl()));

  // =========================================================
  // ======================== PROFILE =========================
  // =========================================================

  // Profile module from profile_injection.dart
  profileModule(sl);

  // =========================================================
  // ======================= DASHBOARD ========================
  // =========================================================

  // Dashboard module from dashboard_injection.dart
  initDashboardDependencies();
}

// Dummy implementation for web platform
class _DummyLocationHistoryRepository implements LocationHistoryRepository {
  @override
  Future<void> storeLocation(LocationHistoryEntity location) async {}

  @override
  Future<List<LocationHistoryEntity>> getAllHistory() async => [];

  @override
  Future<List<LocationHistoryEntity>> getHistorySince(
    DateTime timestamp,
  ) async => [];

  @override
  Future<void> deleteOlderThan(DateTime timestamp) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<int> getCount() async => 0;
}
