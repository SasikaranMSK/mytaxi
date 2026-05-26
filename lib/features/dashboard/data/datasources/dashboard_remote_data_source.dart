import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../models/driver_status_model.dart';
import '../models/vehicle_validation_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<JobModel>> getDriverJobs();
  Future<List<JobModel>> getJobsByStatus(String status);
  Future<List<JobModel>> getNewJobs({
    required String macAddress,
    required int driverId,
    required String vehicleNo,
    required double radius,
    required int vehicleTypeId,
  });
  Future<List<JobModel>> getJobsBySearch({
    required String macAddress,
    int pageNumber = 0,
    int pageSize = 20,
    String? search,
    String? searchColumn,
    String? sortColumnName,
    String? sortDirection,
  });
  Future<JobModel> getJobById(int jobId);
  Future<bool> acceptJob({
    required int jobId,
    required String macAddress,
    required int vehicleId,
  });
  Future<VehicleValidationModel> validateDriverVehicle();
  Future<bool> checkVehicleDocumentsValidity();
  Future<bool> activateVehicle();
  Future<bool> setDriverOnline();
  Future<bool> setDriverOnDuty();
  Future<DriverStatusModel> getLatestShiftStatus(int driverId);
  Future<DriverStatusModel> getDriverStatus();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<List<JobModel>> getDriverJobs() async {
    try {
      final response = await dio.get('/taxis-api/api/Driver/DriverJobs');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => JobModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch driver jobs: $e');
    }
  }

  @override
  Future<List<JobModel>> getJobsByStatus(String status) async {
    try {
      final response = await dio.get(
        '/taxis-api/api/Driver/DriverJobByStatus',
        queryParameters: {'status': status},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => JobModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch jobs by status: $e');
    }
  }

  @override
  Future<List<JobModel>> getNewJobs({
    required String macAddress,
    required int driverId,
    required String vehicleNo,
    required double radius,
    required int vehicleTypeId,
  }) async {
    try {
      final response = await dio.post(
        '/taxis-api/api/Jobs/GetNewJobs',
        data: {
          'macAddress': macAddress,
          'driverId': driverId,
          'vehicleNo': vehicleNo,
          'radius': radius,
          'vehicleTypeId': vehicleTypeId,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => JobModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch new jobs: $e');
    }
  }

  @override
  Future<List<JobModel>> getJobsBySearch({
    required String macAddress,
    int pageNumber = 0,
    int pageSize = 20,
    String? search,
    String? searchColumn,
    String? sortColumnName,
    String? sortDirection,
  }) async {
    try {
      final response = await dio.post(
        '/taxis-api/api/DeviceJobs/$macAddress/GetAllBySearch',
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'search': search ?? '',
          'searchColumn': searchColumn ?? '',
          'sortColumnName': sortColumnName ?? '',
          'sortDirection': sortDirection ?? '',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? response.data['items'] ?? [];
        return data.map((json) => JobModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }

  @override
  Future<JobModel> getJobById(int jobId) async {
    try {
      final response = await dio.get('/taxis-api/api/DeviceJobs/$jobId');
      if (response.statusCode == 200 && response.data != null) {
        return JobModel.fromJson(response.data);
      }
      throw Exception('Job not found');
    } catch (e) {
      throw Exception('Failed to fetch job details: $e');
    }
  }

  @override
  Future<bool> acceptJob({
    required int jobId,
    required String macAddress,
    required int vehicleId,
  }) async {
    try {
      final response = await dio.post(
        '/taxis-api/api/DeviceJobs/Accept',
        data: {
          'jobId': jobId,
          'macAddress': macAddress,
          'vehicleId': vehicleId,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to accept job: $e');
    }
  }

  @override
  Future<VehicleValidationModel> validateDriverVehicle() async {
    try {
      final response = await dio.get(
        '/taxis-api/api/Validations/ValidateDriveVehicles',
      );
      if (response.statusCode == 200 && response.data != null) {
        return VehicleValidationModel.fromJson(response.data);
      }
      throw Exception('Validation failed');
    } catch (e) {
      throw Exception('Failed to validate driver vehicle: $e');
    }
  }

  @override
  Future<bool> checkVehicleDocumentsValidity() async {
    try {
      final response = await dio.get(
        '/taxis-api/api/Document/CheckVehicleDocumentsValidity',
      );
      return response.statusCode == 200 &&
          (response.data == true || response.data['isValid'] == true);
    } catch (e) {
      throw Exception('Failed to check vehicle documents: $e');
    }
  }

  @override
  Future<bool> activateVehicle() async {
    try {
      final response = await dio.get('/taxis-api/api/Driver/ActivateVehicle');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to activate vehicle: $e');
    }
  }

  @override
  Future<bool> setDriverOnline() async {
    try {
      final response = await dio.get('/taxis-api/api/DriverStatus/Online');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to set driver online: $e');
    }
  }

  @override
  Future<bool> setDriverOnDuty() async {
    try {
      final response = await dio.get('/taxis-api/api/DriverStatus/OnDuty');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to set driver on duty: $e');
    }
  }

  @override
  Future<DriverStatusModel> getLatestShiftStatus(int driverId) async {
    try {
      final response = await dio.get(
        '/taxis-api/api/DriverDutyTimes/$driverId/latest-shift',
      );
      if (response.statusCode == 200 && response.data != null) {
        return DriverStatusModel.fromJson(response.data);
      }
      throw Exception('Shift status not found');
    } catch (e) {
      throw Exception('Failed to fetch shift status: $e');
    }
  }

  @override
  Future<DriverStatusModel> getDriverStatus() async {
    try {
      // This combines online and duty status
      final onlineResponse = await dio.get(
        '/taxis-api/api/DriverStatus/Online',
      );
      final dutyResponse = await dio.get('/taxis-api/api/DriverStatus/OnDuty');

      return DriverStatusModel(
        status: 'active',
        isOnline: onlineResponse.statusCode == 200,
        isOnDuty: dutyResponse.statusCode == 200,
        isVehicleActivated: true,
        lastStatusChange: DateTime.now(),
      );
    } catch (e) {
      return const DriverStatusModel(
        status: 'offline',
        isOnline: false,
        isOnDuty: false,
        isVehicleActivated: false,
      );
    }
  }
}
