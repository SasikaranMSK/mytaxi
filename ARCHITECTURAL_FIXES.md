# Architectural Issues - Solutions with Code Comparisons

## 📋 Overview
This document provides before/after code comparisons for fixing the 5 main architectural issues identified in the Meter Taxi app.

---

## 🔴 Issue 1: Mixed GPS Logic - Meter Feature

### ❌ BEFORE (Current - GPS in Widget)

**File**: `lib/features/meter_screen/presentation/pages/taximeter_screen.dart`

```dart
class _TaxiMeterScreenState extends State<TaxiMeterScreen> {
  MeterBloc? _meterBloc;
  
  // ❌ GPS state in widget
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPos;
  double _distanceKm = 0;
  DateTime? _lastMovementTime;
  Timer? _idleCheckTimer;
  
  /* ================= GPS LOGIC ================= */
  
  // ❌ GPS logic in widget - should be in BLoC
  Future<void> _startGps() async {
    _stopGps(); // Clear existing
    _lastPos = null;
    _distanceKm = 0;
    _lastMovementTime = DateTime.now();

    // Start idle checker (Auto Wait Logic)
    _idleCheckTimer?.cancel();
    _idleCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_lastMovementTime != null) {
        final idleDuration = DateTime.now().difference(_lastMovementTime!);
        if (idleDuration.inMinutes >= 1) {
          _meterBloc?.add(const SetWaitingEvent(true));
        }
      }
    });

    // Ensure location service & permission
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // ❌ GPS stream in widget
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      if (_lastPos != null) {
        final meters = Geolocator.distanceBetween(
          _lastPos!.latitude,
          _lastPos!.longitude,
          pos.latitude,
          pos.longitude,
        );

        if (meters > 5 && meters < 500) {
          _distanceKm += meters / 1000;
          _meterBloc?.add(UpdateDistanceEvent(_distanceKm));

          _lastMovementTime = DateTime.now();
          _meterBloc?.add(const SetWaitingEvent(false));
        }
      }
      _lastPos = pos;
    });
  }

  void _stopGps() {
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  void _onStartTrip() {
    _startGps();  // ❌ Widget manages GPS
    _meterBloc?.add(StartMeterEvent());
  }
}
```

### ✅ AFTER (Fixed - GPS in BLoC)

**File**: `lib/features/meter_screen/data/datasources/location_data_source.dart` (New)

```dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position?> getCurrentPosition();
  Stream<Position?> getPositionStream();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Position?> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).handleError((error) => null);
  }

  @override
  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();
}
```

**File**: `lib/features/meter_screen/presentation/bloc/meter_event.dart` (Updated)

```dart
import 'package:equatable/equatable.dart';

abstract class MeterEvent extends Equatable {
  const MeterEvent();
  @override
  List<Object?> get props => [];
}

class StartMeterEvent extends MeterEvent {}

class StopMeterEvent extends MeterEvent {}

// ✅ New event for GPS control
class StartGPSTrackingEvent extends MeterEvent {}
class StopGPSTrackingEvent extends MeterEvent {}

// ✅ Internal event for position updates
class _PositionUpdatedEvent extends MeterEvent {
  final Position position;
  const _PositionUpdatedEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

class UpdateDistanceEvent extends MeterEvent {
  final double distanceKm;
  const UpdateDistanceEvent(this.distanceKm);

  @override
  List<Object?> get props => [distanceKm];
}

class TogglePauseEvent extends MeterEvent {}

class SetWaitingEvent extends MeterEvent {
  final bool isWaiting;
  const SetWaitingEvent(this.isWaiting);
  @override
  List<Object?> get props => [isWaiting];
}

class MeterTickEvent extends MeterEvent {}
class ResetMeterEvent extends MeterEvent {}
```

**File**: `lib/features/meter_screen/presentation/bloc/meter_bloc.dart` (Updated)

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/datasources/location_data_source.dart';
import '../../../tariff/domain/entities/tariff_entity.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../domain/usecases/start_meter.dart';
import '../../domain/usecases/stop_meter.dart';
import '../../domain/usecases/calculate_fare.dart';
import '../../domain/repositories/meter_repository.dart';
import 'meter_event.dart';
import 'meter_state.dart';

class MeterBloc extends Bloc<MeterEvent, MeterState> {
  final StartMeter startMeter;
  final StopMeter stopMeter;
  final CalculateFare calculateFare;
  final MeterRepository repository;
  final VehicleEntity vehicle;
  final TariffEntity tariff;
  final LocationDataSource locationDataSource;  // ✅ Injected

  Timer? _timer;
  Timer? _idleCheckTimer;
  
  // ✅ GPS state now in BLoC
  StreamSubscription<Position?>? _gpsSubscription;
  Position? _lastPosition;
  double _distanceKm = 0;
  DateTime? _lastMovementTime;

  MeterBloc({
    required this.startMeter,
    required this.stopMeter,
    required this.calculateFare,
    required this.repository,
    required this.vehicle,
    required this.tariff,
    required this.locationDataSource,  // ✅ Required dependency
  }) : super(MeterState.initial()) {
    on<StartMeterEvent>(_onStartMeter);
    on<StopMeterEvent>(_onStopMeter);
    on<StartGPSTrackingEvent>(_onStartGPSTracking);  // ✅ New
    on<StopGPSTrackingEvent>(_onStopGPSTracking);    // ✅ New
    on<_PositionUpdatedEvent>(_onPositionUpdated);   // ✅ New
    on<UpdateDistanceEvent>(_onDistanceUpdate);
    on<TogglePauseEvent>(_onTogglePause);
    on<SetWaitingEvent>(_onSetWaiting);
    on<MeterTickEvent>(_onTick);
    on<ResetMeterEvent>(_onResetMeter);
  }

  // ✅ GPS logic now in BLoC
  Future<void> _onStartGPSTracking(
    StartGPSTrackingEvent event,
    Emitter<MeterState> emit,
  ) async {
    // Stop existing subscription
    await _gpsSubscription?.cancel();
    _lastPosition = null;
    _distanceKm = 0;
    _lastMovementTime = DateTime.now();

    // Check location service
    final serviceEnabled = await locationDataSource.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(gpsError: 'Location service is disabled'));
      return;
    }

    // Check permission
    var permission = await locationDataSource.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationDataSource.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(gpsError: 'Location permission denied'));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(gpsError: 'Location permission permanently denied'));
      return;
    }

    // Start idle checker for auto-wait
    _idleCheckTimer?.cancel();
    _idleCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_lastMovementTime != null) {
        final idleDuration = DateTime.now().difference(_lastMovementTime!);
        if (idleDuration.inMinutes >= 1) {
          add(const SetWaitingEvent(true));
        }
      }
    });

    // Start GPS stream
    _gpsSubscription = locationDataSource.getPositionStream().listen(
      (position) {
        if (position != null) {
          add(_PositionUpdatedEvent(position));
        }
      },
      onError: (error) {
        add(StopGPSTrackingEvent());
        emit(state.copyWith(gpsError: error.toString()));
      },
    );

    emit(state.copyWith(gpsError: null));
  }

  Future<void> _onStopGPSTracking(
    StopGPSTrackingEvent event,
    Emitter<MeterState> emit,
  ) async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _idleCheckTimer?.cancel();
    _idleCheckTimer = null;
  }

  // ✅ Handle position updates
  void _onPositionUpdated(
    _PositionUpdatedEvent event,
    Emitter<MeterState> emit,
  ) {
    if (_lastPosition != null) {
      final meters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        event.position.latitude,
        event.position.longitude,
      );

      // Filter GPS jumps and small movements
      if (meters > 5 && meters < 500) {
        _distanceKm += meters / 1000;
        add(UpdateDistanceEvent(_distanceKm));

        // We moved, reset idle timer and disable waiting
        _lastMovementTime = DateTime.now();
        add(const SetWaitingEvent(false));
      }
    }
    _lastPosition = event.position;
  }

  Future<void> _onStartMeter(
    StartMeterEvent event,
    Emitter<MeterState> emit,
  ) async {
    final start = startMeter.call();

    emit(
      state.copyWith(
        isRunning: true,
        isWaiting: false,
        isPaused: false,
        startTime: start,
        endTime: null,
        distance: 0,
        totalFare: tariff.flagFall,
        waitingTime: 0,
      ),
    );

    // ✅ Start GPS tracking
    add(StartGPSTrackingEvent());

    // Start meter timer
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(MeterTickEvent()),
    );
  }

  Future<void> _onStopMeter(
    StopMeterEvent event,
    Emitter<MeterState> emit,
  ) async {
    final end = stopMeter.call();
    
    // ✅ Stop GPS tracking
    add(StopGPSTrackingEvent());
    
    _timer?.cancel();
    _timer = null;

    emit(
      state.copyWith(
        isRunning: false,
        endTime: end,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _idleCheckTimer?.cancel();
    _gpsSubscription?.cancel();
    return super.close();
  }

  // ... other event handlers remain the same
}
```

**File**: `lib/features/meter_screen/presentation/pages/taximeter_screen.dart` (Updated)

```dart
class _TaxiMeterScreenState extends State<TaxiMeterScreen> {
  MeterBloc? _meterBloc;
  bool _ready = false;
  
  // ✅ GPS state removed from widget
  // ❌ Removed: StreamSubscription<Position>? _gpsSub;
  // ❌ Removed: Position? _lastPos;
  // ❌ Removed: double _distanceKm = 0;
  // ❌ Removed: DateTime? _lastMovementTime;
  // ❌ Removed: Timer? _idleCheckTimer;

  @override
  void dispose() {
    WakelockPlus.disable();
    // ✅ No need to stop GPS here - BLoC handles it
    _meterBloc?.close();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final vehicleLocal = sl<VehicleLocalDataSource>();
      final vehicle = await vehicleLocal.getVehicle();

      if (vehicle == null) {
        debugPrint("No vehicle found");
        return;
      }

      var tariffs = await sl<GetActiveTariffsUseCase>()();
      tariffs = vehicle.vehicleTypeId == 2
          ? DefaultTariffs.list.where((t) => t.tarifName.contains("Maxi")).toList()
          : DefaultTariffs.list.where((t) => t.tarifName.contains("Sedan")).toList();

      final selectedTariff = SelectActiveTariffUseCase()(tariffs);

      _meterBloc = MeterBloc(
        startMeter: sl<StartMeter>(),
        stopMeter: sl<StopMeter>(),
        calculateFare: sl<CalculateFare>(),
        repository: sl(),
        vehicle: vehicle.toEntity(),
        tariff: selectedTariff,
        locationDataSource: sl<LocationDataSource>(),  // ✅ Inject data source
      );

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint("Error initializing meter: $e");
    }
  }

  // ✅ GPS methods removed - now in BLoC
  // ❌ Removed: Future<void> _startGps() async { ... }
  // ❌ Removed: void _stopGps() { ... }

  /* ================= ACTIONS ================= */

  void _onStartTrip() {
    // ✅ Simply dispatch event - BLoC handles GPS
    _meterBloc?.add(StartMeterEvent());
  }

  void _onStopTrip() {
    // ✅ BLoC handles GPS cleanup
    _meterBloc?.add(StopMeterEvent());
  }

  void _onCollectPayment() {
    _meterBloc?.add(ResetMeterEvent());
  }

  // ... rest remains the same
}
```

**Update DI Container**: `lib/di/injection_container.dart`

```dart
// Add LocationDataSource
import '../features/meter_screen/data/datasources/location_data_source.dart';

Future<void> initializeDependencies() async {
  // ... existing code ...
  
  // ✅ Register LocationDataSource
  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );
}
```

---

## 🔴 Issue 2: Inconsistent BLoC Creation

### ❌ BEFORE (Inconsistent Patterns)

**Pattern 1: Global BLoC** (Auth)
```dart
// lib/main.dart
class TaxiMeterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())  // ❌ Global
      ],
      child: MaterialApp(...),
    );
  }
}
```

**Pattern 2: Route-Scoped BLoC** (Map)
```dart
// lib/core/config/route/app_router.dart
case RouteConstants.map:
  return MaterialPageRoute(
    builder: (_) => BlocProvider<MapBloc>(  // ❌ Route-scoped
      create: (_) => sl<MapBloc>(),
      child: const _LogoutScaffold(child: MapScreen()),
    ),
  );
```

**Pattern 3: Programmatic BLoC** (Meter)
```dart
// lib/features/meter_screen/presentation/pages/taximeter_screen.dart
class _TaxiMeterScreenState extends State<TaxiMeterScreen> {
  MeterBloc? _meterBloc;  // ❌ Manually created
  
  Future<void> _init() async {
    _meterBloc = MeterBloc(  // ❌ Manual instantiation
      startMeter: sl<StartMeter>(),
      stopMeter: sl<StopMeter>(),
      // ...
    );
  }
  
  Widget build(BuildContext context) {
    return BlocProvider.value(  // ❌ Using BlocProvider.value
      value: _meterBloc!,
      child: Scaffold(...),
    );
  }
}
```

### ✅ AFTER (Standardized Approach)

**Decision Matrix**:
- **Global Scope**: Only for app-wide state (Auth)
- **Route Scope**: For feature-specific state (Map, Meter, Vehicle)
- **Never**: Manual BLoC creation in widgets

**Pattern 1: Global BLoC** (Auth - Keep as is)
```dart
// lib/main.dart - NO CHANGE NEEDED
class TaxiMeterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Auth needs to be global - used across app
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())
      ],
      child: MaterialApp(...),
    );
  }
}
```

**Pattern 2: Route-Scoped BLoC** (Map - Keep as is)
```dart
// lib/core/config/route/app_router.dart - NO CHANGE NEEDED
case RouteConstants.map:
  return MaterialPageRoute(
    builder: (_) => BlocProvider<MapBloc>(
      // ✅ Map BLoC created when route is pushed
      create: (_) => sl<MapBloc>(),
      child: const _LogoutScaffold(child: MapScreen()),
    ),
  );
```

**Pattern 3: Route-Scoped BLoC** (Meter - STANDARDIZE)
```dart
// lib/core/config/route/app_router.dart
case RouteConstants.meter:
  // ✅ Get dependencies upfront
  final vehicleNo = settings.arguments as String?;
  
  return MaterialPageRoute(
    builder: (_) => FutureBuilder<MeterBloc?>(
      future: _createMeterBloc(vehicleNo),  // ✅ Async initialization
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing meter: ${snapshot.error}'),
            ),
          );
        }
        
        // ✅ BLoC created in route, not widget
        return BlocProvider<MeterBloc>.value(
          value: snapshot.data!,
          child: const _LogoutScaffold(
            child: TaxiMeterScreen(),
            backRoute: RouteConstants.vehicle,
          ),
        );
      },
    ),
  );

// ✅ Helper method for async BLoC creation
static Future<MeterBloc?> _createMeterBloc(String? vehicleNo) async {
  try {
    final vehicleLocal = sl<VehicleLocalDataSource>();
    final vehicle = await vehicleLocal.getVehicle();
    
    if (vehicle == null) return null;
    
    var tariffs = await sl<GetActiveTariffsUseCase>()();
    tariffs = vehicle.vehicleTypeId == 2
        ? DefaultTariffs.list.where((t) => t.tarifName.contains("Maxi")).toList()
        : DefaultTariffs.list.where((t) => t.tarifName.contains("Sedan")).toList();
    
    final selectedTariff = SelectActiveTariffUseCase()(tariffs);
    
    return MeterBloc(
      startMeter: sl<StartMeter>(),
      stopMeter: sl<StopMeter>(),
      calculateFare: sl<CalculateFare>(),
      repository: sl(),
      vehicle: vehicle.toEntity(),
      tariff: selectedTariff,
      locationDataSource: sl<LocationDataSource>(),
    );
  } catch (e) {
    debugPrint("Error creating MeterBloc: $e");
    return null;
  }
}
```

**Updated TaxiMeterScreen** (Simplified)
```dart
// lib/features/meter_screen/presentation/pages/taximeter_screen.dart
class TaxiMeterScreen extends StatelessWidget {  // ✅ Now Stateless!
  const TaxiMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ BLoC already provided by route
    return Scaffold(
      backgroundColor: kBgColor,
      bottomNavigationBar: const BottomNavTabs(activeTab: BottomNavTab.fare),
      body: SafeArea(
        child: BlocListener<MeterBloc, MeterState>(
          listener: (context, state) {
            // Handle state changes
          },
          child: BlocBuilder<MeterBloc, MeterState>(
            builder: (context, state) {
              // Build UI based on state
              return _buildMeterUI(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMeterUI(BuildContext context, MeterState state) {
    // ... UI code
  }
}
```

---

## 🔴 Issue 3: Vehicle Entry Lacks BLoC

### ❌ BEFORE (Direct Use Case Calls)

**File**: `lib/features/vehicle/presentation/pages/vehicle_entry_screen.dart`

```dart
class VehicleEntryScreen extends StatefulWidget {
  const VehicleEntryScreen({super.key});

  @override
  State<VehicleEntryScreen> createState() => _VehicleEntryScreenState();
}

class _VehicleEntryScreenState extends State<VehicleEntryScreen> {
  final _vehicleController = TextEditingController();
  bool _loading = false;  // ❌ Local state only

  // ❌ Direct use case calls in widget
  Future<void> _continue() async {
    final vehicleNo = _vehicleController.text.trim();

    setState(() => _loading = true);  // ❌ Manual loading state

    try {
      // ❌ Direct service locator calls
      final usecase = sl<FetchAndSaveVehicleUseCase>();
      final vehicle = await usecase(
        FetchAndSaveVehicleParams(
          networkId: 2,
          vehicleNo: vehicleNo,
        ),
      );

      final tariffUsecase = sl<FetchAndSaveTariffsByVehicleTypeIdV2UseCase>();
      final tariffs = await tariffUsecase(vehicle.vehicleTypeId);

      // Navigation
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/meter', arguments: vehicleNo);
    } catch (e) {
      // ❌ Manual error handling
      if (!mounted) return;
      final raw = e.toString();
      final cleaned = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      final message = cleaned.isNotEmpty ? cleaned : 'Vehicle fetch failed';
      showErrorPopup(context, message: message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _vehicleController,
              // ...
            ),
            ElevatedButton(
              onPressed: _loading ? null : _continue,  // ❌ Manual disable
              child: _loading
                  ? const CircularProgressIndicator()  // ❌ Manual spinner
                  : const Text("CONTINUE"),
            ),
          ],
        ),
      ),
    );
  }
}
```

### ✅ AFTER (With VehicleBloc)

**File**: `lib/features/vehicle/presentation/bloc/vehicle_event.dart` (New)

```dart
import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchVehicleRequested extends VehicleEvent {
  final String vehicleNo;
  final int networkId;

  const FetchVehicleRequested({
    required this.vehicleNo,
    required this.networkId,
  });

  @override
  List<Object?> get props => [vehicleNo, networkId];
}

class ResetVehicleState extends VehicleEvent {}
```

**File**: `lib/features/vehicle/presentation/bloc/vehicle_state.dart` (New)

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();
  
  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final VehicleEntity vehicle;
  final int tariffsCount;

  const VehicleLoaded({
    required this.vehicle,
    required this.tariffsCount,
  });

  @override
  List<Object?> get props => [vehicle, tariffsCount];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**File**: `lib/features/vehicle/presentation/bloc/vehicle_bloc.dart` (New)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fetch_and_save_vehicle_usecase.dart';
import '../../../tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_type_id_v2_usecase.dart';
import '../../../../core/utils/error_handler.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final FetchAndSaveVehicleUseCase fetchVehicleUseCase;
  final FetchAndSaveTariffsByVehicleTypeIdV2UseCase fetchTariffsUseCase;

  VehicleBloc({
    required this.fetchVehicleUseCase,
    required this.fetchTariffsUseCase,
  }) : super(VehicleInitial()) {
    on<FetchVehicleRequested>(_onFetchVehicle);
    on<ResetVehicleState>(_onReset);
  }

  Future<void> _onFetchVehicle(
    FetchVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    try {
      // Fetch vehicle
      final vehicle = await fetchVehicleUseCase(
        FetchAndSaveVehicleParams(
          networkId: event.networkId,
          vehicleNo: event.vehicleNo,
        ),
      );

      // Fetch tariffs
      final tariffs = await fetchTariffsUseCase(vehicle.vehicleTypeId);

      emit(VehicleLoaded(
        vehicle: vehicle,
        tariffsCount: tariffs.length,
      ));
    } catch (e) {
      // ✅ Use centralized error handler (see Issue 4)
      final errorMessage = ErrorHandler.clean(e);
      emit(VehicleError(errorMessage));
    }
  }

  void _onReset(ResetVehicleState event, Emitter<VehicleState> emit) {
    emit(VehicleInitial());
  }
}
```

**File**: `lib/features/vehicle/presentation/pages/vehicle_entry_screen.dart` (Updated)

```dart
class VehicleEntryScreen extends StatelessWidget {  // ✅ Now Stateless
  const VehicleEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A32),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleLoaded) {
            // ✅ Navigate on success
            Navigator.pushReplacementNamed(
              context,
              '/meter',
              arguments: state.vehicle.vehicleNo,
            );
          } else if (state is VehicleError) {
            // ✅ Show error popup
            showErrorPopup(context, message: state.message);
          }
        },
        child: const _VehicleEntryForm(),
      ),
    );
  }
}

class _VehicleEntryForm extends StatefulWidget {
  const _VehicleEntryForm();

  @override
  State<_VehicleEntryForm> createState() => _VehicleEntryFormState();
}

class _VehicleEntryFormState extends State<_VehicleEntryForm> {
  final _vehicleController = TextEditingController();

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    final vehicleNo = _vehicleController.text.trim();
    
    if (vehicleNo.isEmpty) {
      showErrorPopup(context, message: 'Please enter vehicle number');
      return;
    }

    // ✅ Dispatch event to BLoC
    context.read<VehicleBloc>().add(
      FetchVehicleRequested(
        vehicleNo: vehicleNo,
        networkId: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Enter Vehicle Number",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          TextField(
            controller: _vehicleController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: "Vehicle Number",
              prefixIcon: const Icon(Icons.directions_car),
              filled: true,
              fillColor: const Color(0xFF26333D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // ✅ BlocBuilder for loading state
          BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              final isLoading = state is VehicleLoading;
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _onContinue(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("CONTINUE"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

**Update Route**: `lib/core/config/route/app_router.dart`

```dart
case RouteConstants.vehicle:
  return MaterialPageRoute(
    builder: (_) => BlocProvider<VehicleBloc>(  // ✅ Provide VehicleBloc
      create: (_) => sl<VehicleBloc>(),
      child: const _LogoutScaffold(child: VehicleEntryScreen()),
    ),
  );
```

**Update DI**: `lib/di/injection_container.dart`

```dart
// Add VehicleBloc
import '../features/vehicle/presentation/bloc/vehicle_bloc.dart';

Future<void> initializeDependencies() async {
  // ... existing code ...
  
  // ✅ Register VehicleBloc
  sl.registerFactory<VehicleBloc>(
    () => VehicleBloc(
      fetchVehicleUseCase: sl(),
      fetchTariffsUseCase: sl(),
    ),
  );
}
```

---

## 🔴 Issue 4: Error Handling Varies

### ❌ BEFORE (Inconsistent Error Handling)

**Auth BLoC** (Good, but custom)
```dart
catch (e) {
  String errorMessage = e.toString();
  
  // Remove 'Exception: ' prefix if present
  if (errorMessage.startsWith('Exception: ')) {
    errorMessage = errorMessage.substring(11);
  }
  
  errorMessage = errorMessage.trim();
  if (errorMessage.isEmpty) {
    errorMessage = 'Login failed';
  }
  
  emit(AuthFailure(errorMessage));
}
```

**Map BLoC** (Raw error)
```dart
catch (e) {
  emit(state.copyWith(loading: false, error: e.toString()));  // ❌ Raw
}
```

**Vehicle Screen** (Manual regex)
```dart
catch (e) {
  final raw = e.toString();
  final cleaned = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();  // ❌ Regex
  final message = cleaned.isNotEmpty ? cleaned : 'Vehicle fetch failed';
  showErrorPopup(context, message: message);
}
```

**Meter BLoC** (No error handling)
```dart
// ❌ No try-catch in many places
```

### ✅ AFTER (Centralized Error Handler)

**File**: `lib/core/utils/error_handler.dart` (New)

```dart
/// Centralized error handling utility
class ErrorHandler {
  /// Clean error messages by removing common prefixes and formatting
  static String clean(dynamic error, {String? defaultMessage}) {
    if (error == null) {
      return defaultMessage ?? 'An unknown error occurred';
    }

    String message = error.toString();

    // Remove common exception prefixes
    message = message
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '')
        .replaceFirst(RegExp(r'^FormatException:\s*'), '')
        .replaceFirst(RegExp(r'^TypeError:\s*'), '')
        .trim();

    // Return cleaned message or default
    if (message.isEmpty) {
      return defaultMessage ?? 'An error occurred';
    }

    return message;
  }

  /// Get user-friendly error messages
  static String getUserFriendlyMessage(dynamic error) {
    final cleaned = clean(error);

    // Map common errors to user-friendly messages
    if (cleaned.toLowerCase().contains('network')) {
      return 'Network error. Please check your connection.';
    }
    
    if (cleaned.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (cleaned.toLowerCase().contains('unauthorized') ||
        cleaned.toLowerCase().contains('401')) {
      return 'Session expired. Please login again.';
    }
    
    if (cleaned.toLowerCase().contains('not found') ||
        cleaned.toLowerCase().contains('404')) {
      return 'Resource not found.';
    }
    
    if (cleaned.toLowerCase().contains('server') ||
        cleaned.toLowerCase().contains('500')) {
      return 'Server error. Please try again later.';
    }

    return cleaned;
  }

  /// Log error for debugging
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final contextStr = context != null ? '[$context] ' : '';
    debugPrint('${contextStr}Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Handle error with logging and return user message
  static String handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    String? defaultMessage,
    bool userFriendly = false,
  }) {
    logError(error, stackTrace: stackTrace, context: context);
    
    return userFriendly
        ? getUserFriendlyMessage(error)
        : clean(error, defaultMessage: defaultMessage);
  }
}
```

**Updated Auth BLoC**:
```dart
import '../../../../core/utils/error_handler.dart';

Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  
  try {
    final auth = await _login(
      username: event.username,
      password: event.password,
    );

    if (auth == null) {
      emit(AuthFailure('Login failed - no data returned'));
      return;
    }

    emit(AuthSuccess(auth));
  } catch (e, stackTrace) {
    // ✅ Use centralized error handler
    final errorMessage = ErrorHandler.handleError(
      e,
      stackTrace: stackTrace,
      context: 'AuthBloc.login',
      defaultMessage: 'Login failed',
      userFriendly: true,  // Get user-friendly message
    );
    
    emit(AuthFailure(errorMessage));
  }
}
```

**Updated Map BLoC**:
```dart
import '../../../../core/utils/error_handler.dart';

Future<void> _onStart(MapStarted event, Emitter<MapState> emit) async {
  emit(state.copyWith(loading: true, error: null));

  try {
    final first = await ds.getCurrentLocation();

    if (first == null) {
      emit(
        state.copyWith(
          loading: false,
          error: "Location permission denied. Please allow location and refresh.",
        ),
      );
      return;
    }

    // ... rest of code
  } catch (e, stackTrace) {
    // ✅ Use centralized error handler
    final errorMessage = ErrorHandler.handleError(
      e,
      stackTrace: stackTrace,
      context: 'MapBloc.start',
      userFriendly: true,
    );
    
    emit(state.copyWith(loading: false, error: errorMessage));
  }
}
```

**Updated Vehicle BLoC**:
```dart
import '../../../../core/utils/error_handler.dart';

Future<void> _onFetchVehicle(
  FetchVehicleRequested event,
  Emitter<VehicleState> emit,
) async {
  emit(VehicleLoading());

  try {
    final vehicle = await fetchVehicleUseCase(...);
    final tariffs = await fetchTariffsUseCase(...);
    
    emit(VehicleLoaded(vehicle: vehicle, tariffsCount: tariffs.length));
  } catch (e, stackTrace) {
    // ✅ Use centralized error handler
    final errorMessage = ErrorHandler.handleError(
      e,
      stackTrace: stackTrace,
      context: 'VehicleBloc.fetchVehicle',
      defaultMessage: 'Vehicle fetch failed',
      userFriendly: true,
    );
    
    emit(VehicleError(errorMessage));
  }
}
```

---

## 🔴 Issue 5: BuildContext in Repository

### ❌ BEFORE (BuildContext in Domain Layer)

**File**: `lib/features/authentication/domain/repositories/authentication_repository.dart`

```dart
import 'package:flutter/widgets.dart';  // ❌ Flutter import in domain layer
import '../../data/models/auth_model.dart';
import '../../data/models/login_request_model.dart';

abstract class AuthenticationRepository {
  // ❌ BuildContext parameter - domain depends on Flutter framework
  Future<AuthModel?> login(LoginRequestModel request, BuildContext? context);
  Future<void> logout();
  
  String? getUserToken();
  AuthModel? getUserData();
  Future<void> clearUserData();
  Future<void> saveUserData(AuthModel user);
}
```

**File**: `lib/features/authentication/data/repositories/authentication_repository_impl.dart`

```dart
import 'package:flutter/widgets.dart';  // ❌ Flutter dependency

@override
Future<AuthModel?> login(LoginRequestModel request, BuildContext? context) async {
  final loginResponse = await _remoteDataSource.login(request, context);  // ❌ Passing context
  // ...
}
```

**File**: `lib/features/authentication/data/datasources/auth_remote_data_source.dart`

```dart
abstract class AuthRemoteDataSource {
  Future<AuthModel?> login(LoginRequestModel request, BuildContext? context);  // ❌
  // ...
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthModel?> login(LoginRequestModel request, BuildContext? context) async {
    // ❌ Context never actually used!
    final response = await _client.post('/login', data: request.toJson());
    // ...
  }
}
```

### ✅ AFTER (Remove BuildContext)

**File**: `lib/features/authentication/domain/repositories/authentication_repository.dart`

```dart
// ✅ No Flutter imports in domain layer
import '../../data/models/auth_model.dart';
import '../../data/models/login_request_model.dart';

abstract class AuthenticationRepository {
  // ✅ No BuildContext parameter
  Future<AuthModel?> login(LoginRequestModel request);
  Future<void> logout();
  
  String? getUserToken();
  AuthModel? getUserData();
  Future<void> clearUserData();
  Future<void> saveUserData(AuthModel user);
}
```

**File**: `lib/features/authentication/data/repositories/authentication_repository_impl.dart`

```dart
// ✅ No Flutter imports needed
import '../../domain/repositories/authentication_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';
import '../models/login_request_model.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthenticationRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Future<AuthModel?> login(LoginRequestModel request) async {  // ✅ No context
    final loginResponse = await _remoteDataSource.login(request);  // ✅ No context
    if (loginResponse == null) return null;

    final withDevice = loginResponse.copyWith(deviceId: request.macAddress);
    await _localDataSource.saveAuthData(withDevice);
    return withDevice;
  }

  @override
  Future<void> logout() async {
    final token = _localDataSource.token;
    final userName = _localDataSource.userName;

    if (token != null && token.isNotEmpty && 
        userName != null && userName.isNotEmpty) {
      await _remoteDataSource.logout(token, userName);  // ✅ No context
    }

    await _localDataSource.clear();
  }

  // ... other methods remain the same
}
```

**File**: `lib/features/authentication/data/datasources/auth_remote_data_source.dart`

```dart
import '../../../../core/clients/api_client.dart';
import '../models/auth_model.dart';
import '../models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel?> login(LoginRequestModel request);  // ✅ No context
  Future<void> logout(String token, String userName);   // ✅ No context
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthModel?> login(LoginRequestModel request) async {  // ✅ No context
    try {
      final response = await _client.post(
        '/api/Authentication/Login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout(String token, String userName) async {  // ✅ No context
    try {
      await _client.post(
        '/api/Authentication/Logout',
        data: {
          'token': token,
          'userName': userName,
        },
      );
    } catch (e) {
      // Log error but don't throw - logout should always succeed locally
      debugPrint('Logout API call failed: $e');
    }
  }
}
```

**Updated Use Case**:
```dart
class LoginUseCase {
  final AuthenticationRepository _repository;
  final AuthenticationLocalDataSource _localDataSource;

  LoginUseCase(this._repository, this._localDataSource);

  Future<AuthEntity?> call({
    required String username,
    required String password,
  }) async {
    final deviceId = await _getOrCreateDeviceId();

    final request = LoginRequestModel(
      username: username,
      password: password,
      macAddress: deviceId,
    );

    // ✅ No context passed
    final AuthModel? model = await _repository.login(request);
    if (model == null) return null;

    final withDevice = model.copyWith(deviceId: deviceId);
    await _localDataSource.saveAuthData(withDevice);

    return withDevice.toEntity();
  }

  // ... _getOrCreateDeviceId method
}
```

---

## 📊 Summary of Changes

### Issue 1: GPS Logic
- **Before**: GPS stream and distance calculation in StatefulWidget
- **After**: All GPS logic moved to MeterBloc, LocationDataSource abstraction
- **Files Changed**: 
  - Created `location_data_source.dart`
  - Updated `meter_bloc.dart`, `meter_event.dart`, `meter_state.dart`
  - Simplified `taximeter_screen.dart` (removed GPS logic)

### Issue 2: BLoC Creation
- **Before**: 3 different patterns (global, route, programmatic)
- **After**: Standardized to 2 patterns (global for Auth, route for features)
- **Files Changed**:
  - Updated `app_router.dart` (async BLoC creation for Meter)
  - Simplified `taximeter_screen.dart` (from Stateful to Stateless)

### Issue 3: Vehicle Entry
- **Before**: Direct use case calls with setState
- **After**: VehicleBloc with proper event/state management
- **Files Changed**:
  - Created `vehicle_bloc.dart`, `vehicle_event.dart`, `vehicle_state.dart`
  - Updated `vehicle_entry_screen.dart` (Stateless with BlocListener/Builder)
  - Updated `app_router.dart`, `injection_container.dart`

### Issue 4: Error Handling
- **Before**: 4 different error cleaning approaches
- **After**: Centralized ErrorHandler utility
- **Files Changed**:
  - Created `error_handler.dart`
  - Updated all BLoCs to use `ErrorHandler.handleError()`

### Issue 5: BuildContext in Repository
- **Before**: BuildContext parameter in domain/data layers (unused)
- **After**: Removed BuildContext from all repository interfaces and implementations
- **Files Changed**:
  - Updated `authentication_repository.dart` (interface)
  - Updated `authentication_repository_impl.dart`
  - Updated `auth_remote_data_source.dart`
  - Updated `login_usecase.dart`

---

## ✅ Benefits of These Changes

1. **Testability**: GPS logic in BLoC is easily testable, mock LocationDataSource
2. **Consistency**: All features use BLoC pattern uniformly
3. **Maintainability**: Centralized error handling, easier to update
4. **Clean Architecture**: Domain layer independent of Flutter framework
5. **Separation of Concerns**: UI only handles presentation, BLoC handles logic
6. **Type Safety**: Proper state management with compile-time checks
7. **Debugging**: Centralized error logging makes issues easier to track

---

## 🔄 Migration Path

1. **Start with Issue 5** (BuildContext removal) - Simplest, no behavior change
2. **Implement Issue 4** (ErrorHandler) - Create utility, update incrementally
3. **Add Issue 3** (VehicleBloc) - New feature, doesn't break existing code
4. **Fix Issue 2** (BLoC creation) - Refactor routing, update Meter screen
5. **Complete Issue 1** (GPS in BLoC) - Most complex, requires BLoC updates

Each step can be done incrementally without breaking the app!
