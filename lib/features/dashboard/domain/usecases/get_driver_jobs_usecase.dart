import '../entities/job_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDriverJobsUseCase {
  final DashboardRepository repository;

  GetDriverJobsUseCase(this.repository);

  Future<List<JobEntity>> call() async {
    return await repository.getDriverJobs();
  }
}
