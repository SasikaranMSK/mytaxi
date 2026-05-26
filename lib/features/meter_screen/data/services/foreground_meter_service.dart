import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handler that runs in isolate for foreground task
@pragma('vm:entry-point')
class MeterForegroundTaskHandler extends TaskHandler {
  static const String _distanceKey = 'meter_distance';
  static const String _waitingTimeKey = 'meter_waiting_time';
  static const String _lastUpdateKey = 'meter_last_update';
  static const int _waitingChargeDelaySeconds = 5;
  static const int _waitingStatusThresholdSeconds = 10;
  static const double _minMovementMeters = 5.0;
  static const double _maxMovementMeters = 500.0;
  static const double _fastMovementMeters = 12.0;
  static const double _minMovementSpeedMps = 0.8;
  static const double _speedOnlyMovementMps = 2.0;
  static const double _maxAcceptedAccuracyMeters = 80.0;
  static const int _movementConfirmHits = 2;

  Position? _lastPosition;
  double _totalDistance = 0.0;
  int _waitingTime = 0;
  int _currentIdleChargedSeconds = 0;
  int _consecutiveMovementHits = 0;
  DateTime? _lastMovementTime;
  Timer? _waitingTimer;
  StreamSubscription<Position>? _positionSubscription;
  bool _isStreamActive = false;
  SharedPreferences? _prefs; // Cache SharedPreferences instance
  DateTime? _lastSaveTime; // Track last save time for debouncing
  static const Duration _saveInterval = Duration(
    seconds: 5,
  ); // Save every 5 seconds max

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('[ForegroundService] Meter task started');

    // Load saved state and cache SharedPreferences instance
    try {
      _prefs = await SharedPreferences.getInstance();
      final prefs = _prefs!;
      _totalDistance = prefs.getDouble(_distanceKey) ?? 0.0;
      _waitingTime = prefs.getInt(_waitingTimeKey) ?? 0;
      final lastUpdate = prefs.getInt(_lastUpdateKey);
      if (lastUpdate != null) {
        _lastMovementTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      }
    } catch (e) {
      debugPrint('[ForegroundService] Error loading state: $e');
    }

    _lastPosition = null;
    final hasExistingTripProgress = _totalDistance > 0 || _waitingTime > 0;
    if (hasExistingTripProgress) {
      _lastMovementTime ??= DateTime.now();
    } else {
      // New trip: ignore stale persisted timestamp from an old session.
      _lastMovementTime = DateTime.now();
    }
    _currentIdleChargedSeconds = 0;
    _consecutiveMovementHits = 0;

    // Start waiting timer (checks every second)
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastMovementTime != null) {
        final idleDuration = DateTime.now().difference(_lastMovementTime!);
        if (idleDuration.inSeconds >= _waitingChargeDelaySeconds) {
          final idleChargeSeconds =
              idleDuration.inSeconds - _waitingChargeDelaySeconds;
          if (idleChargeSeconds > _currentIdleChargedSeconds) {
            final delta = idleChargeSeconds - _currentIdleChargedSeconds;
            _waitingTime += delta;
            _currentIdleChargedSeconds = idleChargeSeconds;

            // Only save to storage every 5 charged seconds to reduce I/O.
            if (_waitingTime % 5 == 0) {
              _saveState();
            }
          }
        }

        final isWaiting =
            idleDuration.inSeconds >= _waitingStatusThresholdSeconds;
        _sendDataToMain(isWaiting: isWaiting);
      }
    });

    // Start GPS position stream (non-blocking)
    _startPositionStream();
  }

  void _startPositionStream() {
    // Prevent multiple stream starts
    if (_isStreamActive) {
      debugPrint('[ForegroundService] GPS stream already active, skipping');
      return;
    }

    _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 5, // Update every 5 meters
            ),
          ).listen(
            (position) {
              if (_lastPosition != null) {
                final hasReliableAccuracy =
                    position.accuracy <= _maxAcceptedAccuracyMeters &&
                    _lastPosition!.accuracy <= _maxAcceptedAccuracyMeters;

                final meters = Geolocator.distanceBetween(
                  _lastPosition!.latitude,
                  _lastPosition!.longitude,
                  position.latitude,
                  position.longitude,
                );

                // Confirm movement across multiple updates to avoid jitter flips.
                final isMoveCandidate =
                    hasReliableAccuracy &&
                    meters >= _minMovementMeters &&
                    meters < _maxMovementMeters &&
                    (position.speed >= _minMovementSpeedMps ||
                        meters >= _fastMovementMeters);
                final isStrongSpeedMove =
                    position.speed >= _speedOnlyMovementMps;

                if (isMoveCandidate) {
                  _consecutiveMovementHits += 1;
                } else {
                  _consecutiveMovementHits = 0;
                }

                if (_consecutiveMovementHits >= _movementConfirmHits ||
                    isStrongSpeedMove) {
                  if (isMoveCandidate) {
                    _totalDistance += meters / 1000; // Convert to km
                  }
                  _lastMovementTime = DateTime.now();
                  _currentIdleChargedSeconds = 0;
                  _consecutiveMovementHits = 0;
                  _saveState();
                  _sendDataToMain(isWaiting: false);
                }
              }
              _lastPosition = position;
            },
            onError: (error) {
              debugPrint('[ForegroundService] Position stream error: $error');
              _isStreamActive = false;
              // Notify main isolate about GPS loss
              FlutterForegroundTask.sendDataToMain({'gps_status': 'lost'});
            },
            onDone: () {
              debugPrint('[ForegroundService] Position stream closed');
              _isStreamActive = false;
              FlutterForegroundTask.sendDataToMain({'gps_status': 'lost'});
            },
            cancelOnError: false, // Keep stream alive on errors
          );

      _isStreamActive = true;
      // GPS restored
      FlutterForegroundTask.sendDataToMain({'gps_status': 'restored'});
      debugPrint('[ForegroundService] GPS stream started successfully');
    } catch (e) {
      debugPrint('[ForegroundService] Error starting GPS stream: $e');
      _isStreamActive = false;
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      // Just update notification periodically
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Meter Running',
        notificationText:
            'Distance: ${_totalDistance.toStringAsFixed(2)} km | Waiting: ${_waitingTime ~/ 60} min',
      );
    } catch (e) {
      debugPrint('[ForegroundService] Notification update error: $e');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('[ForegroundService] Meter task stopped');
    _waitingTimer?.cancel();
    _waitingTimer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isStreamActive = false;
    _lastPosition = null;

    // Force save on destroy to ensure state is persisted
    await _saveState(force: true);
    _prefs = null;
  }

  @override
  void onReceiveData(Object data) {
    // Handle commands from main isolate
    if (data is Map) {
      final command = data['command'] as String?;
      if (command == 'reset') {
        _totalDistance = 0.0;
        _waitingTime = 0;
        _currentIdleChargedSeconds = 0;
        _consecutiveMovementHits = 0;
        _lastMovementTime = null;
        _lastPosition = null;
        _saveState();
        _sendDataToMain(isWaiting: false);
      }
    }
  }

  Future<void> _saveState({bool force = false}) async {
    // Debounce: only save every 5 seconds unless forced
    if (!force && _lastSaveTime != null) {
      final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
      if (timeSinceLastSave < _saveInterval) {
        return; // Skip save if too soon
      }
    }

    try {
      _prefs ??= await SharedPreferences.getInstance();

      await _prefs!.setDouble(_distanceKey, _totalDistance);
      await _prefs!.setInt(_waitingTimeKey, _waitingTime);
      await _prefs!.setInt(
        _lastUpdateKey,
        (_lastMovementTime ?? DateTime.now()).millisecondsSinceEpoch,
      );
      _lastSaveTime = DateTime.now();
    } catch (e) {
      debugPrint('[ForegroundService] Error saving state: $e');
    }
  }

  void _sendDataToMain({required bool isWaiting}) {
    // Use FlutterForegroundTask API to send data to main isolate
    FlutterForegroundTask.sendDataToMain({
      'distance': _totalDistance,
      'waitingTime': _waitingTime,
      'isWaiting': isWaiting,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// Service to manage foreground task lifecycle
class ForegroundMeterService {
  static final ForegroundMeterService _instance =
      ForegroundMeterService._internal();
  factory ForegroundMeterService() => _instance;
  ForegroundMeterService._internal();

  static const String _isRunningKey = 'foreground_service_running';
  StreamController<Map<String, dynamic>>? _dataController;
  DateTime? _lastServiceStartTime;
  bool _isCallbackRegistered = false;

  Stream<Map<String, dynamic>>? get dataStream => _dataController?.stream;

  /// Initialize the foreground task
  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'meter_foreground_channel',
        channelName: 'Meter Service',
        channelDescription: 'This notification keeps the taxi meter running',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000), // Every 5 seconds
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Start the foreground service
  Future<bool> startService() async {
    // Debounce: prevent starting service too frequently (within 2 seconds)
    if (_lastServiceStartTime != null) {
      final timeSinceLastStart = DateTime.now().difference(
        _lastServiceStartTime!,
      );
      if (timeSinceLastStart.inSeconds < 2) {
        debugPrint('[ForegroundService] Service start debounced - too soon');
        return false;
      }
    }

    // Check if already running
    final prefs = await SharedPreferences.getInstance();

    if (await FlutterForegroundTask.isRunningService) {
      debugPrint('[ForegroundService] Service already running');
      await setupReceivePort();
      return true;
    }

    // Request necessary permissions
    final permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      debugPrint('[ForegroundService] Permissions not granted');
      return false;
    }

    // Start the service
    _lastServiceStartTime = DateTime.now();
    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Meter Running',
      notificationText: 'Tracking your trip...',
      notificationIcon: null,
      notificationButtons: [],
      callback: startCallback,
    );

    await prefs.setBool(_isRunningKey, true);
    await setupReceivePort();
    debugPrint('[ForegroundService] Service started successfully');

    return true;
  }

  /// Setup callback to receive data from isolate (public for reconnection)
  Future<void> setupReceivePort() async {
    // Don't recreate if already set up
    if (_isCallbackRegistered && _dataController != null) {
      debugPrint('[ForegroundService] Receive port already set up');
      return;
    }

    _dataController?.close();
    _dataController = StreamController<Map<String, dynamic>>.broadcast();

    // Use FlutterForegroundTask's callback API to receive data from isolate
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    _isCallbackRegistered = true;
    debugPrint('[ForegroundService] Receive port set up successfully');
  }

  /// Stop the foreground service
  Future<bool> stopService() async {
    debugPrint('[ForegroundService] Stopping service...');

    await FlutterForegroundTask.stopService();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRunningKey, false);

    // Clean up streams and callbacks
    await _dataController?.close();
    _dataController = null;
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    _isCallbackRegistered = false;

    debugPrint('[ForegroundService] Service stopped successfully');

    return true;
  }

  // Callback function for task data
  void _onTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      _dataController?.add(data);
    }
  }

  /// Send command to reset meter data
  Future<void> resetMeterData() async {
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({'command': 'reset'});

      // Also clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('meter_distance');
      await prefs.remove('meter_waiting_time');
      await prefs.remove('meter_last_update');
    }
  }

  /// Check if service is running
  Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    debugPrint('[ForegroundService] Requesting permissions...');

    // 1. Request notification permission (Android 13+)
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      debugPrint('[ForegroundService] Requesting notification permission...');
      final granted =
          await FlutterForegroundTask.requestNotificationPermission();
      if (granted != NotificationPermission.granted) {
        debugPrint('[ForegroundService] Notification permission denied');
        // Continue anyway - notification might work on older Android versions
      }
    }

    // 2. Request POST_NOTIFICATIONS for Android 13+ explicitly
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      debugPrint('[ForegroundService] Notification permission status: $status');
    }

    // 3. Check location service enabled
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      debugPrint('[ForegroundService] Location service disabled');
      return false;
    }

    // 4. Request location permission (whileInUse first)
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      debugPrint('[ForegroundService] Requesting location permission...');
      locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        debugPrint(
          '[ForegroundService] Location permission denied: $locationStatus',
        );
        return false;
      }
    }

    // 5. Request background location for Android 10+ (API 29+)
    // This must be requested AFTER foreground location is granted
    var backgroundLocationStatus = await Permission.locationAlways.status;
    if (!backgroundLocationStatus.isGranted) {
      debugPrint(
        '[ForegroundService] Requesting background location permission...',
      );
      backgroundLocationStatus = await Permission.locationAlways.request();
      debugPrint(
        '[ForegroundService] Background location status: $backgroundLocationStatus',
      );
      // Don't fail if background location denied - whileInUse might be enough
    }

    // 6. Request battery optimization exemption for reliable background operation
    var ignoreOptimization = await Permission.ignoreBatteryOptimizations.status;
    if (!ignoreOptimization.isGranted) {
      debugPrint(
        '[ForegroundService] Requesting battery optimization exemption...',
      );
      await Permission.ignoreBatteryOptimizations.request();
    }

    // 7. Request schedule exact alarm for Android 12+ (API 31+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      debugPrint('[ForegroundService] Requesting exact alarm permission...');
      await Permission.scheduleExactAlarm.request();
    }

    debugPrint('[ForegroundService] All permissions requested successfully');
    return locationStatus.isGranted;
  }
}

/// Callback function for foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MeterForegroundTaskHandler());
}
