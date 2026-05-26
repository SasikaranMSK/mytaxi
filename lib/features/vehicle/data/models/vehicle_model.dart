class VehicleModel {
  final int id;
  final String vehicleNo;
  final int vehicleTypeId;
  final String? devicePhoneNumber;
  final bool active;

  VehicleModel({
    required this.id,
    required this.vehicleNo,
    required this.vehicleTypeId,
    required this.devicePhoneNumber,
    required this.active,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] ?? 0) as int,
      vehicleNo: (json['vehicleNo'] ?? '') as String,
      vehicleTypeId: (json['vehicleTypeId'] ?? 0) as int,
      devicePhoneNumber: json['devicePhoneNumber'] as String?,
      active: (json['active'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleNo': vehicleNo,
    'vehicleTypeId': vehicleTypeId,
    'devicePhoneNumber': devicePhoneNumber,
    'active': active,
  };

  // Mapping is handled via DTO mappers to keep entity decoupled.
}
