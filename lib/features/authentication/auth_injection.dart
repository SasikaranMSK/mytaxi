import 'package:get_it/get_it.dart';

import '../../core/storage/token_storage.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/authentication_repository_impl.dart';
import 'domain/repositories/authentication_repository.dart';
import 'domain/usecases/authentications/login_usecase.dart';
import 'domain/usecases/authentications/logout_usecase.dart';

void authenticationModule(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthenticationLocalDataSource>(
    () => AuthenticationLocalDataSource(sl<TokenStorage>()),
  );
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
}
