import '../entities/job_entity.dart';
import '../entities/driver_status_entity.dart';
import '../entities/vehicle_validation_entity.dart';

abstract class DashboardRepository {
  /// Get all jobs for the logged-in driver
  Future<List<JobEntity>> getDriverJobs();

  /// Get jobs filtered by status
  Future<List<JobEntity>> getJobsByStatus(String status);

  /// Poll for newly assigned jobs
  Future<List<JobEntity>> getNewJobs({
    required String macAddress,
    required int driverId,
    required String vehicleNo,
    required double radius,
    required int vehicleTypeId,
  });

  /// Get jobs for device by MAC address with search/filter
  Future<List<JobEntity>> getJobsBySearch({
    required String macAddress,
    int pageNumber = 0,
    int pageSize = 20,
    String? search,
    String? searchColumn,
    String? sortColumnName,
    String? sortDirection,
  });

  /// Get full details of a single job
  Future<JobEntity> getJobById(int jobId);

  /// Accept a job
  Future<bool> acceptJob({
    required int jobId,
    required String macAddress,
    required int vehicleId,
  });

  /// Validate driver is authorized for the vehicle
  Future<VehicleValidationEntity> validateDriverVehicle();

  /// Check vehicle documents validity
  Future<bool> checkVehicleDocumentsValidity();

  /// Activate vehicle for duty
  Future<bool> activateVehicle();

  /// Set driver status to online
  Future<bool> setDriverOnline();

  /// Set driver status to on duty
  Future<bool> setDriverOnDuty();

  /// Get latest shift/duty time status
  Future<DriverStatusEntity> getLatestShiftStatus(int driverId);

  /// Get current driver status
  Future<DriverStatusEntity> getDriverStatus();
}
