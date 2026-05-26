import 'package:floor/floor.dart';

/// Model class for storing location history in database
@entity
class LocationHistoryModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final double lat;
  final double lng;
  final int timestamp; // Unix timestamp in milliseconds

  const LocationHistoryModel({
    this.id,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  // Mapping is handled via DTO mappers to keep entity decoupled.
}
