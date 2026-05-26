abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

class RefreshJobs extends DashboardEvent {}

class AcceptJob extends DashboardEvent {
  final int jobId;
  final String macAddress;
  final int vehicleId;

  AcceptJob({
    required this.jobId,
    required this.macAddress,
    required this.vehicleId,
  });
}

class RejectJob extends DashboardEvent {
  final int jobId;

  RejectJob(this.jobId);
}

class StartWork extends DashboardEvent {}

class FilterJobsByStatus extends DashboardEvent {
  final String status;

  FilterJobsByStatus(this.status);
}

class ViewJobDetails extends DashboardEvent {
  final int jobId;

  ViewJobDetails(this.jobId);
}

class PollNewJobs extends DashboardEvent {
  final String macAddress;
  final int driverId;
  final String vehicleNo;
  final double radius;
  final int vehicleTypeId;

  PollNewJobs({
    required this.macAddress,
    required this.driverId,
    required this.vehicleNo,
    required this.radius,
    required this.vehicleTypeId,
  });
}
