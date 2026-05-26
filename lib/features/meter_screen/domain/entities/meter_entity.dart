class MeterEntity {
  final String tripId; // ✅ unique
  final double distance; // km
  final int waitingTime; // seconds (only while waiting)
  final double totalFare;
  final DateTime startTime;
  final DateTime? endTime;
  final int tariffId;
  final int vehicleId;

  MeterEntity({
    required this.tripId,
    required this.distance,
    required this.waitingTime,
    required this.totalFare,
    required this.startTime,
    this.endTime,
    required this.tariffId,
    required this.vehicleId,
  });
}
