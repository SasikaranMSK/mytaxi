import '../../repositories/authentication_repository.dart';

class LogoutUseCase {
  final AuthenticationRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> execute() async {
    await _repository.logout();
  }

  Future<void> call() async {
    await execute();
  }
}
