import 'package:floor/floor.dart';

@Entity(tableName: 'meter_trips')
class MeterTripModel {
  @primaryKey
  final String tripId;
  final double distance;
  final int waitingTime;
  final double totalFare;
  final int startTime; // millisecondsSinceEpoch
  final int? endTime; // millisecondsSinceEpoch or null
  final int tariffId;
  final int vehicleId;

  const MeterTripModel({
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
