import '../../domain/entities/job_entity.dart';
import '../../domain/entities/driver_status_entity.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<JobEntity> jobs;
  final DriverStatusEntity driverStatus;
  final JobEntity? selectedJob;

  DashboardLoaded({
    required this.jobs,
    required this.driverStatus,
    this.selectedJob,
  });

  DashboardLoaded copyWith({
    List<JobEntity>? jobs,
    DriverStatusEntity? driverStatus,
    JobEntity? selectedJob,
  }) {
    return DashboardLoaded(
      jobs: jobs ?? this.jobs,
      driverStatus: driverStatus ?? this.driverStatus,
      selectedJob: selectedJob ?? this.selectedJob,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}

class JobAccepted extends DashboardState {
  final JobEntity job;

  JobAccepted(this.job);
}

class JobRejected extends DashboardState {
  final int jobId;

  JobRejected(this.jobId);
}

class WorkStarted extends DashboardState {
  final DriverStatusEntity driverStatus;

  WorkStarted(this.driverStatus);
}

class WorkStartError extends DashboardState {
  final String message;

  WorkStartError(this.message);
}
