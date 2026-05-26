import '../../domain/entities/driver_status_entity.dart';

class DriverStatusModel extends DriverStatusEntity {
  const DriverStatusModel({
    required super.status,
    required super.isOnline,
    required super.isOnDuty,
    required super.isVehicleActivated,
    super.lastStatusChange,
    super.shiftStartTime,
    super.currentJobId,
  });

  factory DriverStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusModel(
      status: json['status']?.toString() ?? 'offline',
      isOnline: json['isOnline'] ?? json['online'] ?? false,
      isOnDuty: json['isOnDuty'] ?? json['onDuty'] ?? false,
      isVehicleActivated:
          json['isVehicleActivated'] ?? json['vehicleActive'] ?? false,
      lastStatusChange: json['lastStatusChange'] != null
          ? DateTime.tryParse(json['lastStatusChange'].toString())
          : json['statusChangedAt'] != null
          ? DateTime.tryParse(json['statusChangedAt'].toString())
          : null,
      shiftStartTime: json['shiftStartTime'] != null
          ? DateTime.tryParse(json['shiftStartTime'].toString())
          : json['dutyStartTime'] != null
          ? DateTime.tryParse(json['dutyStartTime'].toString())
          : null,
      currentJobId:
          json['currentJobId']?.toString() ?? json['activeJobId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'isOnline': isOnline,
      'isOnDuty': isOnDuty,
      'isVehicleActivated': isVehicleActivated,
      'lastStatusChange': lastStatusChange?.toIso8601String(),
      'shiftStartTime': shiftStartTime?.toIso8601String(),
      'currentJobId': currentJobId,
    };
  }
}
