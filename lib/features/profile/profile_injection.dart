import 'package:get_it/get_it.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'presentation/bloc/profile_bloc.dart';

void profileModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl()));

  // BLoC
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(getProfileUseCase: sl(), authLocalDataSource: sl()),
  );
}
