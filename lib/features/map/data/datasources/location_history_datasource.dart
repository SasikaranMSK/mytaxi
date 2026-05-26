import '../dao/location_history_dao.dart';
import '../models/location_history_model.dart';

/// Data source for location history operations
class LocationHistoryDataSource {
  final LocationHistoryDao _dao;

  LocationHistoryDataSource(this._dao);

  /// Store a location history point
  Future<void> storeLocation(LocationHistoryModel model) async {
    await _dao.insertLocationHistory(model);
  }

  /// Get all location history records
  Future<List<LocationHistoryModel>> getAllHistory() async {
    return await _dao.getAllLocationHistory();
  }

  /// Get location history since a specific timestamp
  Future<List<LocationHistoryModel>> getHistorySince(
    DateTime timestamp,
  ) async {
    return await _dao.getLocationHistorySince(
      timestamp.millisecondsSinceEpoch,
    );
  }

  /// Delete location history older than a specific timestamp
  Future<void> deleteOlderThan(DateTime timestamp) async {
    await _dao.deleteOlderThan(timestamp.millisecondsSinceEpoch);
  }

  /// Clear all location history
  Future<void> clearAll() async {
    await _dao.deleteAll();
  }

  /// Get count of stored location points
  Future<int> getCount() async {
    return await _dao.getCount() ?? 0;
  }
}
