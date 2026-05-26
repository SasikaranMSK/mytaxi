class MeterModel {
  final String tripId;
  final double distance;
  final int waitingTime;
  final double totalFare;
  final DateTime startTime;
  final DateTime? endTime;
  final int tariffId;
  final int vehicleId;

  MeterModel({
    required this.tripId,
    required this.distance,
    required this.waitingTime,
    required this.totalFare,
    required this.startTime,
    this.endTime,
    required this.tariffId,
    required this.vehicleId,
  });

  /// Backward compatible:
  /// - If old JSON doesn't have tripId, we generate from startTime + vehicleId.
  factory MeterModel.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['startTime']);
    final vehicleId = (json['vehicleId'] as num).toInt();

    final String id = (json['tripId'] as String?) ??
        "${vehicleId}_${start.millisecondsSinceEpoch}";

    return MeterModel(
      tripId: id,
      distance: (json['distance'] as num).toDouble(),
      waitingTime: (json['waitingTime'] as num).toInt(),
      totalFare: (json['totalFare'] as num).toDouble(),
      startTime: start,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      tariffId: (json['tariffId'] as num).toInt(),
      vehicleId: vehicleId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'distance': distance,
      'waitingTime': waitingTime,
      'totalFare': totalFare,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'tariffId': tariffId,
      'vehicleId': vehicleId,
    };
  }

  MeterModel copyWith({
    double? distance,
    int? waitingTime,
    double? totalFare,
    DateTime? endTime,
  }) {
    return MeterModel(
      tripId: tripId,
      distance: distance ?? this.distance,
      waitingTime: waitingTime ?? this.waitingTime,
      totalFare: totalFare ?? this.totalFare,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      tariffId: tariffId,
      vehicleId: vehicleId,
    );
  }
}
