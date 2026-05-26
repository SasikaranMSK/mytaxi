import '../../domain/entities/job_entity.dart';
import '../../domain/entities/driver_status_entity.dart';
import '../../domain/entities/vehicle_validation_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JobEntity>> getDriverJobs() async {
    return await remoteDataSource.getDriverJobs();
  }

  @override
  Future<List<JobEntity>> getJobsByStatus(String status) async {
    return await remoteDataSource.getJobsByStatus(status);
  }

  @override
  Future<List<JobEntity>> getNewJobs({
    required String macAddress,
    required int driverId,
    required String vehicleNo,
    required double radius,
    required int vehicleTypeId,
  }) async {
    return await remoteDataSource.getNewJobs(
      macAddress: macAddress,
      driverId: driverId,
      vehicleNo: vehicleNo,
      radius: radius,
      vehicleTypeId: vehicleTypeId,
    );
  }

  @override
  Future<List<JobEntity>> getJobsBySearch({
    required String macAddress,
    int pageNumber = 0,
    int pageSize = 20,
    String? search,
    String? searchColumn,
    String? sortColumnName,
    String? sortDirection,
  }) async {
    return await remoteDataSource.getJobsBySearch(
      macAddress: macAddress,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
      searchColumn: searchColumn,
      sortColumnName: sortColumnName,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<JobEntity> getJobById(int jobId) async {
    return await remoteDataSource.getJobById(jobId);
  }

  @override
  Future<bool> acceptJob({
    required int jobId,
    required String macAddress,
    required int vehicleId,
  }) async {
    return await remoteDataSource.acceptJob(
      jobId: jobId,
      macAddress: macAddress,
      vehicleId: vehicleId,
    );
  }

  @override
  Future<VehicleValidationEntity> validateDriverVehicle() async {
    return await remoteDataSource.validateDriverVehicle();
  }

  @override
  Future<bool> checkVehicleDocumentsValidity() async {
    return await remoteDataSource.checkVehicleDocumentsValidity();
  }

  @override
  Future<bool> activateVehicle() async {
    return await remoteDataSource.activateVehicle();
  }

  @override
  Future<bool> setDriverOnline() async {
    return await remoteDataSource.setDriverOnline();
  }

  @override
  Future<bool> setDriverOnDuty() async {
    return await remoteDataSource.setDriverOnDuty();
  }

  @override
  Future<DriverStatusEntity> getLatestShiftStatus(int driverId) async {
    return await remoteDataSource.getLatestShiftStatus(driverId);
  }

  @override
  Future<DriverStatusEntity> getDriverStatus() async {
    return await remoteDataSource.getDriverStatus();
  }
}
