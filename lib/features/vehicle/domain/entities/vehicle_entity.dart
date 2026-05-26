class VehicleEntity {
  final int id;
  final String vehicleNo;
  final int vehicleTypeId;
  final String? devicePhoneNumber;
  final bool active;

  const VehicleEntity({
    required this.id,
    required this.vehicleNo,
    required this.vehicleTypeId,
    required this.devicePhoneNumber,
    required this.active,
  });
}
