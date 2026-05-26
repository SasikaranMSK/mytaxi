import '../repositories/dashboard_repository.dart';

class AcceptJobUseCase {
  final DashboardRepository repository;

  AcceptJobUseCase(this.repository);

  Future<bool> call({
    required int jobId,
    required String macAddress,
    required int vehicleId,
  }) async {
    return await repository.acceptJob(
      jobId: jobId,
      macAddress: macAddress,
      vehicleId: vehicleId,
    );
  }
}
