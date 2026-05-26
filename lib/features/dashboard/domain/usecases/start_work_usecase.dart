import '../entities/driver_status_entity.dart';
import '../repositories/dashboard_repository.dart';

class StartWorkUseCase {
  final DashboardRepository repository;

  StartWorkUseCase(this.repository);

  Future<StartWorkResult> call() async {
    try {
      // Step 1: Validate driver vehicle
      final validation = await repository.validateDriverVehicle();
      if (!validation.isDriverAuthorized) {
        return StartWorkResult(
          success: false,
          message: 'Driver not authorized for this vehicle',
        );
      }

      // Step 2: Check vehicle documents
      final documentsValid = await repository.checkVehicleDocumentsValidity();
      if (!documentsValid) {
        return StartWorkResult(
          success: false,
          message: 'Vehicle documents are invalid or expired',
        );
      }

      // Step 3: Activate vehicle
      final vehicleActivated = await repository.activateVehicle();
      if (!vehicleActivated) {
        return StartWorkResult(
          success: false,
          message: 'Failed to activate vehicle',
        );
      }

      // Step 4: Set driver online
      final isOnline = await repository.setDriverOnline();
      if (!isOnline) {
        return StartWorkResult(
          success: false,
          message: 'Failed to set driver online',
        );
      }

      // Step 5: Set driver on duty
      final isOnDuty = await repository.setDriverOnDuty();
      if (!isOnDuty) {
        return StartWorkResult(
          success: false,
          message: 'Failed to set driver on duty',
        );
      }

      // Get updated status
      final status = await repository.getDriverStatus();

      return StartWorkResult(
        success: true,
        message: 'Successfully started work',
        driverStatus: status,
      );
    } catch (e) {
      return StartWorkResult(
        success: false,
        message: 'Error starting work: $e',
      );
    }
  }
}

class StartWorkResult {
  final bool success;
  final String message;
  final DriverStatusEntity? driverStatus;

  StartWorkResult({
    required this.success,
    required this.message,
    this.driverStatus,
  });
}
