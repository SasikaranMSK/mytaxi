import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tariff/domain/entities/tariff_entity.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../domain/usecases/start_meter.dart';
import '../../domain/usecases/stop_meter.dart';
import '../../domain/usecases/calculate_fare.dart';
import '../../domain/repositories/meter_repository.dart';
import '../../domain/entities/meter_entity.dart';
import '../../data/services/foreground_meter_service.dart';
import 'meter_event.dart';
import 'meter_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MeterBloc extends Bloc<MeterEvent, MeterState> {
  final StartMeter startMeter;
  final StopMeter stopMeter;
  final CalculateFare calculateFare;
  final MeterRepository repository;
  final VehicleEntity vehicle;
  final TariffEntity tariff;

  // timer used to tick UI when meter is running
  Timer? _tickTimer;

  // track distance to infer idle (waiting) when foreground service unavailable
  double _lastTickDistance = 0.0;
  int _idleSeconds = 0;

  StreamSubscription? _foregroundDataSubscription;
  StreamSubscription<dynamic>? _connectivitySubscription;
  String? _lastGpsStatus;
  String? _lastConnectivityStatus;
  final ForegroundMeterService _foregroundService = ForegroundMeterService();
  static const double _distanceEpsilonKm = 0.005; // ~5 meters
  static const int _waitingEpsilonSec = 1;

  Future<void> _notifyViaForegroundOrLog(String title, String body) async {
    try {
      if (await _foregroundService.isServiceRunning()) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: body,
        );
      } else {
        debugPrint('[Alert] $title: $body');
      }
    } catch (e) {
      debugPrint('[Alert] Failed to notify: $e');
    }
  }

  MeterBloc({
    required this.startMeter,
    required this.stopMeter,
    required this.calculateFare,
    required this.repository,
    required this.vehicle,
    required this.tariff,
  }) : super(MeterState.initial()) {
    on<StartMeterEvent>(_onStartMeter);
    on<StopMeterEvent>(_onStopMeter);
    on<UpdateDistanceEvent>(_onDistanceUpdate);
    on<TogglePauseEvent>(_onTogglePause);
    on<SetWaitingEvent>(_onSetWaiting);
    on<MeterTickEvent>(_onTick);
    on<ResetMeterEvent>(_onResetMeter);
    on<RestoreStateEvent>(_onRestoreState);
    on<UpdateFromForegroundEvent>(_onUpdateFromForeground);

    // Initialize foreground service asynchronously (don't block constructor)
    _initializeForegroundService().catchError((error) {
      debugPrint('[MeterBloc] Error initializing foreground service: $error');
    });
  }

  Future<void> _initializeForegroundService() async {
    await _foregroundService.initialize();

    // Check if service is already running and restore state
    final isRunning = await _foregroundService.isServiceRunning();
    if (isRunning) {
      // Setup receive port to listen to foreground service data
      await _foregroundService.setupReceivePort();
      add(RestoreStateEvent());
    }
    // Start connectivity monitoring
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final ConnectivityResult status =
          results.isNotEmpty ? results.first : ConnectivityResult.none;

      final statusText = status == ConnectivityResult.none ? 'offline' : 'online';
      if (statusText != _lastConnectivityStatus) {
        _lastConnectivityStatus = statusText;
        if (status == ConnectivityResult.none) {
          await _notifyViaForegroundOrLog('Offline', 'No internet connectivity');
        } else {
          await _notifyViaForegroundOrLog('Online', 'Internet connection restored');
        }
      }
    });
  }

  void _onResetMeter(ResetMeterEvent event, Emitter<MeterState> emit) async {
    // Stop the tick timer as we are resetting
    _stopTickTimer();

    // Stop foreground service and clear data
    await _foregroundService.stopService();
    await _foregroundService.resetMeterData();

    // Clear saved state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('meter_start_time');
    await prefs.remove('meter_is_running');
    await prefs.remove('meter_distance');
    await prefs.remove('meter_waiting_time');
    await prefs.remove('meter_total_fare');

    emit(MeterState.initial());
  }

  Future<void> _onStartMeter(
    StartMeterEvent event,
    Emitter<MeterState> emit,
  ) async {
    final start = startMeter.call();

    // Convert flagFall from cents to dollars for initial display
    final initialFare = tariff.flagFall / 100.0;

    // reset idle tracking
    _lastTickDistance = 0.0;
    _idleSeconds = 0;

    emit(
      state.copyWith(
        isRunning: true,
        isWaiting: false,
        isPaused: false,
        startTime: start,
        endTime: null,
        distance: 0,
        totalFare: initialFare,
        waitingTime: 0,
        tick: 0,
      ),
    );

    // start timer after emitting initial state so UI begins updating
    _startTickTimer();

    // Save state to persist across app restarts
    _saveState();

    // No periodic fare tick: background service sends updates to recalculate fare

    // Start foreground service asynchronously (don't block UI)
    _foregroundService
        .startService()
        .then((serviceStarted) {
          if (serviceStarted) {
            // Listen to foreground service data
            _foregroundDataSubscription?.cancel();
            _foregroundDataSubscription = _foregroundService.dataStream?.listen(
              (data) {
                // Handle GPS status events
                if (data.containsKey('gps_status')) {
                  final status = data['gps_status'] as String?;
                  if (status != null && status != _lastGpsStatus) {
                    _lastGpsStatus = status;
                    if (status == 'lost') {
                      _notifyViaForegroundOrLog('GPS Signal', 'GPS signal lost');
                    } else if (status == 'restored') {
                      _notifyViaForegroundOrLog('GPS Signal', 'GPS signal restored');
                    }
                  }
                  return;
                }

                // Regular distance/waiting updates
                final dist = (data['distance'] as double?) ?? state.distance;
                final wait = (data['waitingTime'] as int?) ?? state.waitingTime;
                final isWaiting =
                    (data['isWaiting'] as bool?) ?? (state.isWaiting);
                add(
                  UpdateFromForegroundEvent(
                    distance: dist,
                    waitingTime: wait,
                    isWaiting: isWaiting,
                  ),
                );
              },
            );
          }
        })
        .catchError((error) {
          debugPrint('[MeterBloc] Error starting foreground service: $error');
        });

    // Notify trip started (updates foreground notification if running)
    await _notifyViaForegroundOrLog('Trip Started', 'Trip has started');
  }

  void _onTogglePause(TogglePauseEvent event, Emitter<MeterState> emit) {
    if (!state.isRunning) return;
    final newState = state.copyWith(isPaused: !state.isPaused);
    emit(newState);

    // pause/resume tick timer accordingly
    if (newState.isPaused) {
      _stopTickTimer();
    } else if (newState.isRunning) {
      _startTickTimer();
    }
  }

  void _onSetWaiting(SetWaitingEvent event, Emitter<MeterState> emit) {
    if (!state.isRunning || state.isPaused) return;
    // Only update if state changed
    if (state.isWaiting != event.isWaiting) {
      emit(state.copyWith(isWaiting: event.isWaiting));
    }
  }

  void _onTick(MeterTickEvent event, Emitter<MeterState> emit) {
    if (!state.isRunning || state.isPaused) return;

    // Idle detection: if distance hasn't changed significantly, count seconds
    if ((state.distance - _lastTickDistance).abs() < _distanceEpsilonKm) {
      _idleSeconds++;
    } else {
      _idleSeconds = 0;
    }
    _lastTickDistance = state.distance;

    int newWaiting = state.waitingTime;
    // After one minute idle, start counting waiting seconds
    if (_idleSeconds > 60) {
      newWaiting += 1;
    }

    double newFare = state.totalFare;
    if (newWaiting != state.waitingTime) {
      newFare = calculateFare.call(
        distance: state.distance,
        waitingTimeInSeconds: newWaiting,
        flagFall: tariff.flagFall,
        distanceRatePerKm: tariff.distanceRate,
        distanceRateRange: tariff.distanceRateRange,
        distanceRate2PerKm: tariff.distanceRate2,
        waitingTimeRatePerMinute: tariff.timeRate,
      );
    }

    emit(state.copyWith(
      tick: state.tick + 1,
      waitingTime: newWaiting,
      totalFare: newFare,
    ));
  }

  void _onDistanceUpdate(UpdateDistanceEvent event, Emitter<MeterState> emit) {
    if (!state.isRunning || state.isPaused) return;
    if (event.distanceKm < 0) return;

    if ((event.distanceKm - state.distance).abs() < _distanceEpsilonKm) {
      return;
    }

    // Recalculate fare immediately when distance changes
    final fare = calculateFare.call(
      distance: event.distanceKm,
      waitingTimeInSeconds: state.waitingTime,
      flagFall: tariff.flagFall,
      distanceRatePerKm: tariff.distanceRate,
      distanceRateRange: tariff.distanceRateRange,
      distanceRate2PerKm: tariff.distanceRate2,
      waitingTimeRatePerMinute:
          tariff.timeRate, // Use timeRate for waiting time charges
    );

    emit(state.copyWith(distance: event.distanceKm, totalFare: fare));
  }

  Future<void> _onStopMeter(StopMeterEvent event, Emitter<MeterState> emit) async {
    if (!state.isRunning || state.startTime == null) return;

    _stopTickTimer();
    _foregroundDataSubscription?.cancel();

    // Stop foreground service
    await _foregroundService.stopService();

    final endTime = stopMeter.call();

    final tripId = "${vehicle.id}_${state.startTime!.millisecondsSinceEpoch}";

    // make sure fare is up to date before recording
    final latestFare = calculateFare.call(
      distance: state.distance,
      waitingTimeInSeconds: state.waitingTime,
      flagFall: tariff.flagFall,
      distanceRatePerKm: tariff.distanceRate,
      distanceRateRange: tariff.distanceRateRange,
      distanceRate2PerKm: tariff.distanceRate2,
      waitingTimeRatePerMinute: tariff.timeRate,
    );

    final trip = MeterEntity(
      tripId: tripId,
      distance: state.distance,
      waitingTime: state.waitingTime,
      totalFare: latestFare,
      startTime: state.startTime!,
      endTime: endTime,
      tariffId: tariff.tarifId,
      vehicleId: vehicle.id,
    );

    try {
      await repository.saveTrip(trip);
      debugPrint('[MeterBloc] Trip saved successfully: $tripId');
    } catch (error) {
      debugPrint('[MeterBloc] Error saving trip: $error');
    }

    // Update foreground notification or log when trip stops
    await _notifyViaForegroundOrLog(
      'Trip Stopped',
      'Trip ended. Fare: ${trip.totalFare.toStringAsFixed(2)}',
    );

    emit(
      state.copyWith(
        isRunning: false,
        isWaiting: false,
        isPaused: false,
        endTime: endTime,
        totalFare: latestFare,
      ),
    );

    await _saveState();
  }

  Future<void> _onRestoreState(
    RestoreStateEvent event,
    Emitter<MeterState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool('meter_is_running') ?? false;

      if (isRunning) {
        final startTimeMs = prefs.getInt('meter_start_time');
        final distance = prefs.getDouble('meter_distance') ?? 0.0;
        final waitingTime = prefs.getInt('meter_waiting_time') ?? 0;

        if (startTimeMs != null) {
          final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);

          // Try to restore saved total fare if available, otherwise recalc
          final prefs = await SharedPreferences.getInstance();
          final savedFare = prefs.getDouble('meter_total_fare');
          final fare = savedFare ?? calculateFare.call(
            distance: distance,
            waitingTimeInSeconds: waitingTime,
            flagFall: tariff.flagFall,
            distanceRatePerKm: tariff.distanceRate,
            distanceRateRange: tariff.distanceRateRange,
            distanceRate2PerKm: tariff.distanceRate2,
            waitingTimeRatePerMinute:
                tariff.timeRate, // Use timeRate for waiting time charges
          );

          emit(
            state.copyWith(
              isRunning: true,
              startTime: startTime,
              distance: distance,
              waitingTime: waitingTime,
              totalFare: fare,
              isPaused: false,
              isWaiting: false,
            ),
          );

          // start tick timer as we are running again
          _startTickTimer();

          // Reconnect to foreground service
          _foregroundDataSubscription?.cancel();
          _foregroundDataSubscription = _foregroundService.dataStream?.listen(
            (data) {
              if (data.containsKey('gps_status')) {
                final status = data['gps_status'] as String?;
                    if (status != null && status != _lastGpsStatus) {
                  _lastGpsStatus = status;
                  if (status == 'lost') {
                    _notifyViaForegroundOrLog('GPS Signal', 'GPS signal lost');
                  } else if (status == 'restored') {
                    _notifyViaForegroundOrLog('GPS Signal', 'GPS signal restored');
                  }
                }
                return;
              }

              final dist = (data['distance'] as double?) ?? state.distance;
              final wait = (data['waitingTime'] as int?) ?? state.waitingTime;
              final isWaiting =
                  (data['isWaiting'] as bool?) ?? state.isWaiting;
              add(
                UpdateFromForegroundEvent(
                  distance: dist,
                  waitingTime: wait,
                  isWaiting: isWaiting,
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint('[MeterBloc] Error restoring state: $e');
    }
  }

  void _onUpdateFromForeground(
    UpdateFromForegroundEvent event,
    Emitter<MeterState> emit,
  ) {
    if (!state.isRunning || state.isPaused) return;

    final safeDistance = event.distance >= state.distance ? event.distance : state.distance;
    final safeWaitingTime = event.waitingTime >= state.waitingTime ? event.waitingTime : state.waitingTime;

    final distanceChanged = (safeDistance - state.distance).abs() >= _distanceEpsilonKm;
    final waitingChanged = (safeWaitingTime - state.waitingTime).abs() >= _waitingEpsilonSec;
    final waitingFlagChanged = state.isWaiting != event.isWaiting;
    if (!distanceChanged && !waitingChanged && !waitingFlagChanged) {
      return;
    }

    // Update distance and waiting time from foreground service
    final fare = calculateFare.call(
      distance: safeDistance,
      waitingTimeInSeconds: safeWaitingTime,
      flagFall: tariff.flagFall,
      distanceRatePerKm: tariff.distanceRate,
      distanceRateRange: tariff.distanceRateRange,
      distanceRate2PerKm: tariff.distanceRate2,
      waitingTimeRatePerMinute:
          tariff.timeRate, // Use timeRate for waiting time charges
    );

    emit(
      state.copyWith(
        distance: safeDistance,
        waitingTime: safeWaitingTime,
        totalFare: fare,
        isWaiting: event.isWaiting,
      ),
    );
    // keep idle tracker in sync with new distance
    _lastTickDistance = safeDistance;

    if (distanceChanged || waitingChanged) {
      _saveState();
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _foregroundDataSubscription?.cancel();
    return super.close();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('meter_is_running', state.isRunning);
      if (state.startTime != null) {
        await prefs.setInt(
          'meter_start_time',
          state.startTime!.millisecondsSinceEpoch,
        );
      }
      await prefs.setDouble('meter_distance', state.distance);
      await prefs.setInt('meter_waiting_time', state.waitingTime);
      // Persist last calculated total fare so UI/restore shows exact value
      await prefs.setDouble('meter_total_fare', state.totalFare);
    } catch (e) {
      debugPrint('[MeterBloc] Error saving state: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // helpers for the UI tick timer
  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(MeterTickEvent());
    });
  }

  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  
}
