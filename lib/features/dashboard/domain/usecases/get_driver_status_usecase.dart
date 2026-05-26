import '../entities/driver_status_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDriverStatusUseCase {
  final DashboardRepository repository;

  GetDriverStatusUseCase(this.repository);

  Future<DriverStatusEntity> call() async {
    return await repository.getDriverStatus();
  }
}
