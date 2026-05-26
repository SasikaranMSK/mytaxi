import 'package:flutter/material.dart';
import 'route_persistence_service.dart';

/// RouteObserver that automatically saves route changes
class RoutePersistenceObserver extends RouteObserver<PageRoute<dynamic>> {
  final RoutePersistenceService _routePersistenceService;

  RoutePersistenceObserver(this._routePersistenceService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('📍 Route Observer - didPush: ${route.settings.name}');
    _saveRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      debugPrint('📍 Route Observer - didReplace: ${newRoute.settings.name}');
      _saveRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      debugPrint('📍 Route Observer - didPop: ${previousRoute.settings.name}');
      _saveRoute(previousRoute);
    }
  }

  void _saveRoute(Route<dynamic> route) {
    if (route is PageRoute && route.settings.name != null) {
      debugPrint('💾 Route Observer - Saving route: ${route.settings.name}');
      _routePersistenceService.saveLastRoute(route.settings.name!);
    } else {
      debugPrint('⚠️ Route Observer - Route has no name or not PageRoute');
    }
  }
}
