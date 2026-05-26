import 'package:floor/floor.dart';
import '../models/location_history_model.dart';

@dao
abstract class LocationHistoryDao {
  /// Insert a new location history record
  @insert
  Future<int> insertLocationHistory(LocationHistoryModel locationHistory);

  /// Get all location history records
  @Query('SELECT * FROM LocationHistoryModel ORDER BY timestamp DESC')
  Future<List<LocationHistoryModel>> getAllLocationHistory();

  /// Get location history records newer than a specific timestamp
  @Query(
    'SELECT * FROM LocationHistoryModel WHERE timestamp > :timestamp ORDER BY timestamp DESC',
  )
  Future<List<LocationHistoryModel>> getLocationHistorySince(int timestamp);

  /// Delete location history records older than a specific timestamp
  @Query('DELETE FROM LocationHistoryModel WHERE timestamp < :timestamp')
  Future<void> deleteOlderThan(int timestamp);

  /// Delete all location history records
  @Query('DELETE FROM LocationHistoryModel')
  Future<void> deleteAll();

  /// Get count of location history records
  @Query('SELECT COUNT(*) FROM LocationHistoryModel')
  Future<int?> getCount();
}
