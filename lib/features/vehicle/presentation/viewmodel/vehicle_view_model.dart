import '../../domain/entities/vehicle_entity.dart';

class VehicleViewModel {
  final int id;
  final String vehicleNo;
  final int vehicleTypeId;
  final String? devicePhoneNumber;
  final bool active;

  // UI helpers
  String get vehicleNoText => vehicleNo.trim().toUpperCase();
  String get statusText => active ? 'Active' : 'Inactive';
  String get phoneText => (devicePhoneNumber == null || devicePhoneNumber!.trim().isEmpty)
      ? '—'
      : devicePhoneNumber!.trim();

  const VehicleViewModel({
    required this.id,
    required this.vehicleNo,
    required this.vehicleTypeId,
    required this.devicePhoneNumber,
    required this.active,
  });

  factory VehicleViewModel.fromEntity(VehicleEntity e) {
    return VehicleViewModel(
      id: e.id,
      vehicleNo: e.vehicleNo,
      vehicleTypeId: e.vehicleTypeId,
      devicePhoneNumber: e.devicePhoneNumber,
      active: e.active,
    );
  }
}
