import '../entities/location_history_entity.dart';

/// Repository interface for location history operations
abstract class LocationHistoryRepository {
  /// Store a location point in history
  Future<void> storeLocation(LocationHistoryEntity location);

  /// Get all location history
  Future<List<LocationHistoryEntity>> getAllHistory();

  /// Get location history since a specific timestamp
  Future<List<LocationHistoryEntity>> getHistorySince(DateTime timestamp);

  /// Delete location history older than a specific timestamp
  Future<void> deleteOlderThan(DateTime timestamp);

  /// Clear all location history
  Future<void> clearAll();

  /// Get count of stored location points
  Future<int> getCount();
}
