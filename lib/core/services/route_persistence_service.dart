import 'package:shared_preferences/shared_preferences.dart';
import '../constants/route_constants.dart';

/// Service to persist and restore the last opened route
class RoutePersistenceService {
  static const String _lastRouteKey = 'last_route';
  final SharedPreferences _prefs;

  RoutePersistenceService(this._prefs);

  /// Save the current route to SharedPreferences
  Future<void> saveLastRoute(String route) async {
    // Only save routes that should be restored (exclude login and summary)
    // Summary requires arguments and can't be restored
    if (route != RouteConstants.login && route != RouteConstants.summary) {
      await _prefs.setString(_lastRouteKey, route);
    }
  }

  /// Get the last saved route
  String? getLastRoute() {
    return _prefs.getString(_lastRouteKey);
  }

  /// Clear the saved route (e.g., on logout)
  Future<void> clearLastRoute() async {
    await _prefs.remove(_lastRouteKey);
  }

  /// Check if there's a saved route
  bool hasSavedRoute() {
    return _prefs.containsKey(_lastRouteKey);
  }
}
