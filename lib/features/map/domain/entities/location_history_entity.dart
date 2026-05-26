import 'package:equatable/equatable.dart';

/// Entity representing a historical location point
class LocationHistoryEntity extends Equatable {
  final int? id;
  final double lat;
  final double lng;
  final DateTime timestamp;

  const LocationHistoryEntity({
    this.id,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, lat, lng, timestamp];
}
