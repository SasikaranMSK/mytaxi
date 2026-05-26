class DriverStatusEntity {
  final String status;
  final bool isOnline;
  final bool isOnDuty;
  final bool isVehicleActivated;
  final DateTime? lastStatusChange;
  final DateTime? shiftStartTime;
  final String? currentJobId;

  const DriverStatusEntity({
    required this.status,
    required this.isOnline,
    required this.isOnDuty,
    required this.isVehicleActivated,
    this.lastStatusChange,
    this.shiftStartTime,
    this.currentJobId,
  });

  DriverStatusEntity copyWith({
    String? status,
    bool? isOnline,
    bool? isOnDuty,
    bool? isVehicleActivated,
    DateTime? lastStatusChange,
    DateTime? shiftStartTime,
    String? currentJobId,
  }) {
    return DriverStatusEntity(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      isVehicleActivated: isVehicleActivated ?? this.isVehicleActivated,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      currentJobId: currentJobId ?? this.currentJobId,
    );
  }
}
