class VehicleDto {
  final int id;
  final String vehicleNo;
  final int vehicleTypeId;
  final String? devicePhoneNumber;
  final bool active;

  VehicleDto({
    required this.id,
    required this.vehicleNo,
    required this.vehicleTypeId,
    required this.devicePhoneNumber,
    required this.active,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as int,
      vehicleNo: json['vehicleNo'] as String,
      vehicleTypeId: json['vehicleTypeId'] as int,
      devicePhoneNumber: json['devicePhoneNumber'] as String?,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleNo': vehicleNo,
    'vehicleTypeId': vehicleTypeId,
    'devicePhoneNumber': devicePhoneNumber,
    'active': active,
  };
}
