import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/route/app_router.dart';
import 'core/config/navigation_service.dart';
import 'core/constants/route_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/route_persistence_service.dart';
import 'core/services/route_persistence_observer.dart';
import 'core/storage/token_storage.dart';
import 'di/injection_container.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  // Initialize foreground task callback (required for Android 12+)
  try {
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (isMobile) {
      FlutterForegroundTask.initCommunicationPort();
    }
  } catch (_) {
    // Ignore on unsupported platforms (web/desktop)
  }

  runApp(const TaxiMeterApp());
}

class TaxiMeterApp extends StatefulWidget {
  const TaxiMeterApp({super.key});

  static TaxiMeterAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<TaxiMeterAppState>();

  @override
  TaxiMeterAppState createState() => TaxiMeterAppState();
}

class TaxiMeterAppState extends State<TaxiMeterApp> {
  late final RoutePersistenceObserver _routeObserver;
  String _initialRoute = RouteConstants.login;
  String? _restoredRoute;
  bool _isLoading = true;
  bool _hasNavigated = false;

  // theme settings
  bool _isDark = true;
  bool _largeText = false;

  // expose current settings
  bool get isDark => _isDark;
  bool get largeText => _largeText;

  void toggleDark() {
    setState(() {
      _isDark = !_isDark;
    });
    sl<SharedPreferences>().setBool('darkMode', _isDark);
  }

  void toggleLargeText() {
    setState(() {
      _largeText = !_largeText;
    });
    sl<SharedPreferences>().setBool('largeText', _largeText);
  }

  /// Load saved preferences (theme and text size) if available.
  void _loadPreferences() {
    try {
      final prefs = sl<SharedPreferences>();
      if (prefs.containsKey('darkMode')) {
        _isDark = prefs.getBool('darkMode') ?? _isDark;
      }
      if (prefs.containsKey('largeText')) {
        _largeText = prefs.getBool('largeText') ?? _largeText;
      }
    } catch (_) {
      // ignore if prefs not ready yet
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _routeObserver = RoutePersistenceObserver(sl<RoutePersistenceService>());

    try {
      final tokenStorage = sl<TokenStorage>();
      final token = await tokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final routePersistenceService = sl<RoutePersistenceService>();
        final savedRoute = routePersistenceService.getLastRoute();

        debugPrint('🔍 Route Persistence - Saved route: $savedRoute');

        const restorableRoutes = [
          RouteConstants.meter,
          RouteConstants.map,
          RouteConstants.profile,
        ];

        if (savedRoute != null &&
            savedRoute != RouteConstants.login &&
            savedRoute != RouteConstants.vehicle &&
            restorableRoutes.contains(savedRoute)) {
          _initialRoute = RouteConstants.vehicle;
          _restoredRoute = savedRoute;
          debugPrint(
            '✅ Route Persistence - Will navigate to: $savedRoute after vehicle',
          );
        } else {
          _initialRoute = RouteConstants.vehicle;
          _restoredRoute = null;
          debugPrint(
            '⚠️ Route Persistence - Going to vehicle (saved: $savedRoute)',
          );
        }
      } else {
        _initialRoute = RouteConstants.login;
        _restoredRoute = null;
        final routePersistenceService = sl<RoutePersistenceService>();
        await routePersistenceService.clearLastRoute();
        debugPrint('🚫 Route Persistence - No token, going to login');
      }
    } catch (e) {
      _initialRoute = RouteConstants.login;
      _restoredRoute = null;
      debugPrint('❌ Route Persistence - Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_restoredRoute != null && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_hasNavigated &&
            rootNavigatorKey.currentContext != null) {
          _hasNavigated = true;
          debugPrint(
            '🔄 Route Persistence - Navigating to restored route: $_restoredRoute',
          );
          Navigator.of(
            rootNavigatorKey.currentContext!,
          ).pushNamed(_restoredRoute!);
        }
      });
    }

    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        navigatorObservers: [_routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'Taxi Meter',
        theme: _isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: _initialRoute,
        builder: (context, child) {
          final isMobile = !kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS);
          Widget w = child ?? const SizedBox();
          w = MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(_largeText ? 1.3 : 1.0)),
            child: w,
          );
          if (isMobile) {
            return WithForegroundTask(child: w);
          }
          return w;
        },
      ),
    );
  }
}
