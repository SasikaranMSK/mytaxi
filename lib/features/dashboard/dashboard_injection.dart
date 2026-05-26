import 'package:get_it/get_it.dart';

import 'data/datasources/dashboard_remote_data_source.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_driver_jobs_usecase.dart';
import 'domain/usecases/accept_job_usecase.dart';
import 'domain/usecases/start_work_usecase.dart';
import 'domain/usecases/get_driver_status_usecase.dart';
import 'presentation/bloc/dashboard_bloc.dart';

final sl = GetIt.instance;

void initDashboardDependencies() {
  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDriverJobsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptJobUseCase(sl()));
  sl.registerLazySingleton(() => StartWorkUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverStatusUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getDriverJobs: sl(),
      acceptJob: sl(),
      startWork: sl(),
      getDriverStatus: sl(),
    ),
  );
}
