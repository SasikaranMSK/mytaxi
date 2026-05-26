# Architecture Analysis: UI → State → Use Case Flow

## 📋 Executive Summary

**Architecture Pattern**: Clean Architecture with **BLoC (Business Logic Component)** state management
**Additional Patterns**: StatefulWidget for local UI state
**DI Framework**: GetIt (Service Locator)

---

## 🏗️ Overall Architecture Pattern

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Pages     │  │     Bloc     │  │   Widgets    │      │
│  │   (UI/Screens)│ │  (State Mgmt)│ │  (Reusable)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           ↕
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entities   │  │  Use Cases   │  │ Repositories │      │
│  │ (Pure Models)│  │(Business Logic)│ │ (Interfaces) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           ↕
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Models    │  │ Data Sources │  │ Repository   │      │
│  │  (DTOs/JSON) │  │ (Remote/Local)│ │Implementation│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 State Management Analysis

### Primary Pattern: **BLoC (Business Logic Component)**

The app uses `flutter_bloc` package for state management with the following structure:

#### BLoC Components:
1. **Events**: User actions or system triggers
2. **States**: UI representation states
3. **BLoC**: Business logic that transforms events into states

### State Management Comparison by Feature:

| Feature | State Management | Pattern | Notes |
|---------|-----------------|---------|-------|
| Authentication | **BLoC** | Event-State | Global state via MultiBlocProvider |
| Map | **BLoC** | Event-State | Local BlocProvider in route |
| Meter | **BLoC** | Event-State | Created programmatically in StatefulWidget |
| Vehicle Entry | **StatefulWidget** | Local setState | Simple loading state only |
| Tariff | **None** | Use Case only | No presentation layer state |

### ✅ No Provider, MVVM, or Cubit Detected
- **Provider/ChangeNotifier**: Not used
- **Cubit**: Not used (uses full BLoC pattern)
- **MVVM**: Not used (uses BLoC instead)

---

## 📱 Authentication Feature - Complete Flow

### Screen Flow Diagram

```
┌─────────────────┐
│   LoginPage     │
│  (Stateless)    │
└────────┬────────┘
         │
         │ contains
         ↓
┌─────────────────┐
│   LoginForm     │
│  (StatefulWidget)│ ← Manages text controllers & local UI state
└────────┬────────┘     (_obscure password, _rememberMe checkbox)
         │
         │ BlocBuilder/BlocListener
         ↓
┌─────────────────┐
│    AuthBloc     │
└────────┬────────┘
         │
         │ Events
         ↓
┌─────────────────┐
│  LoginRequested │ ─────┐
│ LogoutRequested │      │
└─────────────────┘      │
         ↑               │
         │               │ Event Handler
         │               ↓
         │      ┌──────────────────┐
         │      │   _onLogin()     │
         │      │   _onLogout()    │
         │      └────────┬─────────┘
         │               │
         │               │ Calls Use Case
         │               ↓
         │      ┌──────────────────┐
         │      │  LoginUseCase    │
         │      │  LogoutUseCase   │
         │      └────────┬─────────┘
         │               │
         │               │ Calls Repository
         │               ↓
         │      ┌──────────────────────────┐
         │      │ AuthenticationRepository │
         │      └────────┬─────────────────┘
         │               │
         │               │ Returns AuthModel
         │               ↓
         │      ┌──────────────────┐
         │      │   toEntity()     │
         │      └────────┬─────────┘
         │               │
         │               │ Emits State
         ↓               ↓
┌─────────────────────────────────┐
│        AuthState                │
│  • AuthInitial                  │
│  • AuthLoading    ← Loading UI  │
│  • AuthSuccess    ← Navigate    │
│  • AuthFailure    ← Show Error  │
│  • AuthLoggedOut  ← Clear & Nav │
└─────────────────────────────────┘
```

### Detailed Authentication Flow

#### 1️⃣ **UI Layer** (LoginPage)
- **File**: `lib/features/authentication/presentation/pages/login_page.dart`
- **Pattern**: Stateless widget with BlocListener
- **Responsibilities**:
  - Listens to `AuthState` changes
  - Navigates on `AuthSuccess` → Vehicle screen
  - Shows error popup on `AuthFailure`

#### 2️⃣ **Widget Layer** (LoginForm)
- **File**: `lib/features/authentication/presentation/widgets/login_form.dart`
- **Pattern**: StatefulWidget
- **Local State**:
  ```dart
  - _username: TextEditingController
  - _password: TextEditingController
  - _obscure: bool (password visibility)
  - _rememberMe: bool (checkbox state)
  ```
- **BLoC Integration**:
  ```dart
  BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      return LoginButton(
        loading: state is AuthLoading,  // ← Disable button on loading
        onPressed: () {
          context.read<AuthBloc>().add(
            LoginRequested(
              _username.text.trim(),
              _password.text.trim(),
            ),
          );
        },
      );
    },
  )
  ```

#### 3️⃣ **BLoC Layer** (AuthBloc)
- **File**: `lib/features/authentication/presentation/bloc/auth_bloc.dart`
- **Events**:
  ```dart
  abstract class AuthEvent {}
  class LoginRequested extends AuthEvent {
    final String username;
    final String password;
  }
  class LogoutRequested extends AuthEvent {}
  ```
- **States**:
  ```dart
  abstract class AuthState {}
  class AuthInitial extends AuthState {}
  class AuthLoading extends AuthState {}          // ← Shows loading indicator
  class AuthSuccess extends AuthState {
    final AuthEntity auth;
  }
  class AuthFailure extends AuthState {
    final String message;                         // ← Shows error popup
  }
  class AuthLoggedOut extends AuthState {}        // ← Triggers navigation
  ```

#### 4️⃣ **Event Handler** (_onLogin)
```dart
Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());                            // ← State 1: Loading
  
  try {
    final auth = await _login(                    // ← Call use case
      username: event.username,
      password: event.password,
    );

    if (auth == null) {
      emit(AuthFailure('Login failed'));          // ← State 2a: Error
      return;
    }

    emit(AuthSuccess(auth));                      // ← State 2b: Success
  } catch (e) {
    String errorMessage = e.toString()
      .replaceFirst('Exception: ', '')
      .trim();
    emit(AuthFailure(errorMessage));              // ← State 2c: Exception
  }
}
```

#### 5️⃣ **Use Case Layer** (LoginUseCase)
- **File**: `lib/features/authentication/domain/usecases/authentications/login_usecase.dart`
- **Dependencies**:
  - `AuthenticationRepository` (domain interface)
  - `AuthenticationLocalDataSource` (data persistence)
- **Business Logic**:
  1. Get or create device ID
  2. Create login request model
  3. Call repository.login()
  4. Save auth data locally
  5. Convert Model → Entity
  6. Return AuthEntity

#### 6️⃣ **Repository Layer** (AuthenticationRepository)
- **File**: `lib/features/authentication/domain/repositories/authentication_repository.dart`
- **Interface**:
  ```dart
  abstract class AuthenticationRepository {
    Future<AuthModel?> login(LoginRequestModel request, BuildContext? context);
    Future<void> logout();
    String? getUserToken();
    AuthModel? getUserData();
  }
  ```

#### 7️⃣ **State Response in UI**

| State | UI Response | Implementation |
|-------|-------------|----------------|
| `AuthLoading` | - Disable login button<br>- Show loading spinner | BlocBuilder checks `state is AuthLoading` |
| `AuthSuccess` | - Navigate to vehicle screen<br>- Clear login form | BlocListener + Navigator.pushReplacementNamed() |
| `AuthFailure` | - Show error popup<br>- Re-enable login button | BlocListener + showErrorPopup() |
| `AuthLoggedOut` | - Navigate to login screen<br>- Clear all routes | BlocListener in _LogoutScaffold |

---

## 🗺️ Map Feature - Complete Flow

### Screen Flow Diagram

```
┌──────────────────┐
│   MapScreen      │
│ (StatefulWidget) │
└────────┬─────────┘
         │
         │ initState: add(MapStarted)
         │ dispose: add(MapStopped)
         ↓
┌──────────────────┐
│    MapBloc       │
└────────┬─────────┘
         │
         │ Events
         ↓
┌─────────────────────────────┐
│  MapStarted                 │ ← User opens screen
│  MapStopped                 │ ← User closes screen
│  MapLocationUpdated         │ ← GPS stream update
└────────┬────────────────────┘
         │
         │ Event Handlers
         ↓
┌─────────────────────────────┐
│  _onStart()                 │
│   ├─ ds.getCurrentLocation()│ ← Use Data Source
│   ├─ emit loading/error     │
│   └─ ds.streamLocation()    │ ← Start GPS stream
│                             │
│  _onUpdated()               │
│   ├─ emit new lat/lng       │
│   └─ storeLocationHistory   │ ← Use Case
│                             │
│  _onStop()                  │
│   └─ cancel stream          │
└────────┬────────────────────┘
         │
         │ Emits State
         ↓
┌─────────────────────────────┐
│      MapState               │
│  • loading: bool            │
│  • error: String?           │
│  • lat: double?             │ ← Updates FlutterMap
│  • lng: double?             │
└─────────────────────────────┘
```

### State Management Details

#### MapState Structure
```dart
class MapState extends Equatable {
  final bool loading;
  final String? error;
  final double? lat;
  final double? lng;
  
  // Uses copyWith pattern for immutability
  MapState copyWith({...}) { ... }
}
```

#### Loading, Success, Error Handling

| Scenario | State Values | UI Response |
|----------|-------------|-------------|
| **Initial Load** | `loading: true, lat: null, lng: null` | Show CircularProgressIndicator |
| **Permission Denied** | `loading: false, error: "Permission denied", lat: null` | Show error message |
| **Location Loaded** | `loading: false, error: null, lat: 9.66, lng: 80.02` | Show map with marker |
| **Location Updated** | `loading: false, error: null, lat: 9.67, lng: 80.03` | Move map camera to new position |
| **Stream Error** | `loading: false, error: "GPS error"` | Show error message |

#### GPS Stream Integration
```dart
// In _onStart event handler
_sub = ds.streamLocation().listen(
  (loc) {
    if (loc == null) return;  // Handle null (permission lost)
    add(MapLocationUpdated(lat: loc.lat, lng: loc.lng));
  },
  onError: (e) {
    add(MapStopped());
    emit(state.copyWith(loading: false, error: e.toString()));
  },
);
```

---

## 🚕 Meter Feature - Complex Flow

### Screen Flow Diagram

```
┌────────────────────────┐
│  TaxiMeterScreen       │
│   (StatefulWidget)     │
└───────┬────────────────┘
        │
        │ initState: _init()
        │  ├─ Load vehicle from local storage
        │  ├─ Load tariffs from local storage
        │  └─ Create MeterBloc programmatically
        ↓
┌────────────────────────┐
│     MeterBloc          │
│  (Created in Widget)   │ ← NOT provided globally
└───────┬────────────────┘
        │
        │ Events
        ↓
┌──────────────────────────────────┐
│  StartMeterEvent                 │ ← User starts trip
│  StopMeterEvent                  │ ← User stops trip
│  UpdateDistanceEvent             │ ← GPS distance update
│  TogglePauseEvent                │ ← User pauses meter
│  SetWaitingEvent(isWaiting)      │ ← Auto-wait (idle detection)
│  MeterTickEvent                  │ ← Timer (every 1 second)
│  ResetMeterEvent                 │ ← User collects payment
└───────┬──────────────────────────┘
        │
        │ Event Handlers + Use Cases
        ↓
┌──────────────────────────────────┐
│  _onStartMeter()                 │
│   ├─ startMeter.call()           │ ← Returns DateTime.now()
│   ├─ emit running state          │
│   └─ Start Timer.periodic        │
│                                  │
│  _onDistanceUpdate()             │
│   ├─ emit new distance           │
│   └─ calculateFare.call()        │ ← Business logic
│                                  │
│  _onTick()                       │
│   ├─ Update waiting time         │
│   └─ calculateFare.call()        │ ← Recalculate every second
│                                  │
│  _onStopMeter()                  │
│   ├─ stopMeter.call()            │ ← Returns DateTime.now()
│   ├─ Cancel timer                │
│   └─ emit stopped state          │
└───────┬──────────────────────────┘
        │
        │ Emits State
        ↓
┌──────────────────────────────────┐
│        MeterState                │
│  • isRunning: bool               │
│  • isWaiting: bool               │
│  • isPaused: bool                │
│  • startTime: DateTime?          │
│  • endTime: DateTime?            │
│  • distance: double              │
│  • totalFare: double             │ ← Calculated by use case
│  • waitingTime: int (seconds)    │
└──────────────────────────────────┘
```

### GPS Integration in Widget (Not BLoC)

**Unique Pattern**: GPS logic is in the StatefulWidget, NOT in BLoC!

```dart
class _TaxiMeterScreenState extends State<TaxiMeterScreen> {
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPos;
  double _distanceKm = 0;
  DateTime? _lastMovementTime;
  
  // Widget manages GPS, sends events to BLoC
  void _onStartTrip() {
    _startGps();                    // ← Start GPS stream (in widget)
    _meterBloc?.add(StartMeterEvent());  // ← Notify BLoC
  }
  
  // GPS stream listener
  _gpsSub = Geolocator.getPositionStream(...).listen((pos) {
    if (_lastPos != null) {
      final meters = Geolocator.distanceBetween(...);
      if (meters > 5 && meters < 500) {
        _distanceKm += meters / 1000;
        _meterBloc?.add(UpdateDistanceEvent(_distanceKm));  // ← Send to BLoC
        
        // Auto-wait logic (in widget!)
        _lastMovementTime = DateTime.now();
        _meterBloc?.add(const SetWaitingEvent(false));
      }
    }
  });
}
```

### State Handling

| State Field | UI Response | Logic Location |
|-------------|-------------|----------------|
| `isRunning` | Show/hide START/STOP buttons | BLoC |
| `isWaiting` | Show "WAITING" badge | BLoC (triggered by widget) |
| `isPaused` | Show "PAUSED" badge | BLoC |
| `totalFare` | Display fare amount | BLoC (CalculateFare use case) |
| `distance` | Display distance | Widget → BLoC via event |
| `waitingTime` | Display waiting duration | BLoC (incremented on tick) |

---

## 🚗 Vehicle Entry - Simple Pattern

### Flow Diagram

```
┌────────────────────────┐
│ VehicleEntryScreen     │
│  (StatefulWidget)      │
└───────┬────────────────┘
        │
        │ Local State Only
        │  • _loading: bool
        │  • _vehicleController: TextEditingController
        │
        │ _continue() method
        ↓
┌────────────────────────┐
│ Direct Use Case Call   │ ← NO BLoC!
│  ├─ sl<FetchAndSaveVehicleUseCase>()
│  ├─ sl<FetchAndSaveTariffsUseCase>()
│  └─ Navigator.pushReplacementNamed()
└────────────────────────┘
```

**Pattern**: Simple loading state with `setState()`, no BLoC needed.

---

## 🔄 State Management Decision Tree

```
                    Need State Management?
                            │
                    ┌───────┴───────┐
                    │               │
                   YES              NO
                    │               │
                    │               ↓
                    │         Use StatefulWidget
                    │         with local setState
                    │               │
         ┌──────────┴────────┐      └─ Example: Vehicle Entry
         │                   │
    Global State?      Feature State?
         │                   │
         ↓                   ↓
    MultiBlocProvider   BlocProvider in route
         │                   │
         └─ Auth             └─ Map
         
    Programmatic Creation?
         │
         ↓
    Create in StatefulWidget
         │
         └─ Meter (complex initialization)
```

---

## 📊 Dependency Injection Pattern

### GetIt Service Locator

**File**: `lib/di/injection_container.dart`

```dart
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Infrastructure
  sl.registerSingleton<AppDatabase>(database);
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<Dio>(dio);
  
  // Data Sources (Singleton)
  sl.registerSingleton<AuthLocalDataSource>(...);
  sl.registerSingleton<AuthRemoteDataSource>(...);
  
  // Repositories (Singleton)
  sl.registerSingleton<AuthenticationRepository>(
    AuthenticationRepositoryImpl(sl(), sl())
  );
  
  // Use Cases (Factory - new instance each time)
  sl.registerFactory(() => LoginUseCase(sl(), sl()));
  sl.registerFactory(() => LogoutUseCase(sl(), sl()));
  
  // BLoC (Factory - new instance per screen)
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerFactory(() => MapBloc(ds: sl(), storeLocationHistoryUseCase: sl()));
}
```

### Usage in App

```dart
// In main.dart - Global BLoC
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())
  ],
  child: MaterialApp(...)
)

// In route - Local BLoC
BlocProvider<MapBloc>(
  create: (_) => sl<MapBloc>(),
  child: MapScreen()
)

// In widget - Direct use case
final usecase = sl<FetchAndSaveVehicleUseCase>();
await usecase(params);
```

---

## 🔍 Architectural Issues & Improvements

### ✅ Current Strengths

1. **Clean Architecture**: Clear separation of concerns
2. **Consistent BLoC Pattern**: Most features use BLoC properly
3. **Immutable States**: Using `copyWith()` and Equatable
4. **Use Case Separation**: Business logic isolated from UI
5. **Dependency Injection**: Centralized with GetIt

### ⚠️ Issues Identified

#### 1. **Mixed State Management**
**Problem**: Meter feature has GPS logic in StatefulWidget instead of BLoC
```dart
// Current: GPS in widget
class _TaxiMeterScreenState {
  StreamSubscription<Position>? _gpsSub;
  _gpsSub = Geolocator.getPositionStream(...).listen(...);
}
```
**Impact**: 
- Harder to test
- State scattered between widget and BLoC
- Violates Single Responsibility Principle

**Recommendation**: Move GPS logic to BLoC
```dart
class MeterBloc {
  final LocationDataSource locationDataSource;
  StreamSubscription? _gpsSub;
  
  void _onStartMeter(...) {
    _gpsSub = locationDataSource.streamPosition().listen((pos) {
      add(LocationUpdated(pos));
    });
  }
}
```

#### 2. **Inconsistent BLoC Creation**
**Problem**: Auth is global, Map is route-scoped, Meter is programmatic
```dart
// Auth (Global)
MultiBlocProvider(providers: [BlocProvider<AuthBloc>(create: (_) => sl())])

// Map (Route)
BlocProvider<MapBloc>(create: (_) => sl<MapBloc>())

// Meter (Programmatic)
_meterBloc = MeterBloc(startMeter: sl(), ...)
```
**Recommendation**: Standardize approach
- Global: Auth (needed across app)
- Route-scoped: Map, Meter (feature-specific)
- Avoid manual BLoC creation in widgets

#### 3. **Vehicle Entry Doesn't Use BLoC**
**Problem**: Direct use case calls in widget with local loading state
```dart
setState(() => _loading = true);
final usecase = sl<FetchAndSaveVehicleUseCase>();
final vehicle = await usecase(...);
```
**Impact**: 
- No error state management (only try-catch)
- Can't track loading state in tests
- Inconsistent with other features

**Recommendation**: Add VehicleBloc
```dart
// Events
class FetchVehicleRequested extends VehicleEvent {
  final String vehicleNo;
}

// States
class VehicleLoading extends VehicleState {}
class VehicleLoaded extends VehicleState {
  final VehicleEntity vehicle;
}
class VehicleError extends VehicleState {
  final String message;
}
```

#### 4. **Error Handling Inconsistencies**
**Problem**: Different error handling approaches
- Auth: Clean error messages (remove "Exception:" prefix)
- Map: Raw error toString()
- Meter: No visible error handling
- Vehicle: Manual regex cleaning

**Recommendation**: Create centralized error handler
```dart
class ErrorHandler {
  static String clean(dynamic error) {
    final raw = error.toString();
    return raw
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .replaceFirst(RegExp(r'^Error:\s*'), '')
      .trim();
  }
}
```

#### 5. **No Loading State Composition**
**Problem**: Each feature reimplements loading states
```dart
class AuthState { /* has loading */ }
class MapState { final bool loading; }
class MeterState { /* no loading field */ }
```
**Recommendation**: Use sealed classes or status enum
```dart
enum Status { initial, loading, success, failure }

class AuthState {
  final Status status;
  final AuthEntity? data;
  final String? error;
}
```

#### 6. **Missing Repository Abstraction in Meter**
**Problem**: MeterBloc receives repository but doesn't use it
```dart
class MeterBloc {
  final MeterRepository repository;  // ← Injected but unused
  // All logic is in-memory calculations
}
```
**Recommendation**: Either use repository or remove dependency

#### 7. **BuildContext in Repository Interface**
**Problem**: AuthenticationRepository.login() accepts BuildContext?
```dart
Future<AuthModel?> login(LoginRequestModel request, BuildContext? context);
```
**Impact**: 
- Violates Clean Architecture (domain depends on framework)
- Makes testing harder
- Unnecessary coupling

**Recommendation**: Remove BuildContext, use callbacks or events if needed

---

## 📈 Recommended Architecture Improvements

### 1. **Standardize BLoC Pattern Across All Features**

```dart
// Every feature should have:
presentation/
  ├── bloc/
  │   ├── feature_bloc.dart
  │   ├── feature_event.dart
  │   └── feature_state.dart
  ├── pages/
  │   └── feature_page.dart  (Stateless, uses BlocBuilder/BlocListener)
  └── widgets/
      └── feature_widget.dart
```

### 2. **Create Base Classes**

```dart
// Base State with Status Pattern
abstract class BaseState<T> extends Equatable {
  final Status status;
  final T? data;
  final String? error;
  
  const BaseState({
    this.status = Status.initial,
    this.data,
    this.error,
  });
  
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isFailure => status == Status.failure;
}

// Usage
class AuthState extends BaseState<AuthEntity> {
  const AuthState({
    super.status,
    super.data,
    super.error,
  });
}
```

### 3. **Extract GPS to Dedicated BLoC or Data Source**

```dart
// Create dedicated LocationBloc or enhance MapBloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationDataSource dataSource;
  StreamSubscription? _sub;
  
  void _onStart(...) {
    _sub = dataSource.streamPosition().listen((pos) {
      add(LocationUpdated(pos));
    });
  }
}

// MeterBloc subscribes to LocationBloc
class MeterBloc extends Bloc<MeterEvent, MeterState> {
  final LocationBloc locationBloc;
  StreamSubscription? _locationSub;
  
  void _onStart(...) {
    _locationSub = locationBloc.stream.listen((locationState) {
      if (locationState is LocationSuccess) {
        add(UpdateDistance(locationState.position));
      }
    });
  }
}
```

### 4. **Add BLoC Testing**

```dart
// Example test structure
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  
  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authBloc = AuthBloc(mockLoginUseCase, MockLogoutUseCase());
  });
  
  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSuccess] when login succeeds',
    build: () {
      when(() => mockLoginUseCase(username: any, password: any))
          .thenAnswer((_) async => mockAuthEntity);
      return authBloc;
    },
    act: (bloc) => bloc.add(LoginRequested('user', 'pass')),
    expect: () => [
      AuthLoading(),
      AuthSuccess(mockAuthEntity),
    ],
  );
}
```

---

## 🎨 UI → State → Use Case Flow Summary

### Authentication Flow
```
LoginForm (Widget)
    ↓ User taps login button
LoginRequested (Event)
    ↓ Handled by AuthBloc
AuthLoading (State) → UI shows loading
    ↓ Calls LoginUseCase
LoginUseCase.call()
    ↓ Calls Repository
AuthenticationRepository.login()
    ↓ Returns AuthModel
AuthEntity (Domain Entity)
    ↓ Emitted as State
AuthSuccess(AuthEntity) → UI navigates
```

### Map Flow
```
MapScreen.initState()
    ↓ Dispatch event
MapStarted (Event)
    ↓ Handled by MapBloc
MapState(loading: true) → UI shows loader
    ↓ Calls Data Source
LocationDataSource.getCurrentLocation()
    ↓ Stream location updates
MapLocationUpdated (Event) [every GPS update]
    ↓ Handled by MapBloc
MapState(lat: X, lng: Y) → UI updates map
    ↓ Side effect
StoreLocationHistoryUseCase() → Saves to DB
```

### Meter Flow
```
TaxiMeterScreen._onStartTrip()
    ↓ Start GPS + dispatch event
StartMeterEvent
    ↓ Handled by MeterBloc
MeterState(isRunning: true, totalFare: flagFall)
    ↓ Start timer (every 1 sec)
MeterTickEvent
    ↓ Calls Use Case
CalculateFare(distance, waitingTime, tariff)
    ↓ Emits updated state
MeterState(totalFare: calculated) → UI updates
    ↓ GPS update (in widget)
UpdateDistanceEvent(newDistance)
    ↓ Recalculates fare
MeterState(distance: X, totalFare: Y) → UI updates
```

---

## 📋 Feature-by-Feature State Management

### Authentication
- **Pattern**: BLoC (Global scope)
- **States**: Initial, Loading, Success, Failure, LoggedOut
- **Events**: LoginRequested, LogoutRequested
- **Use Cases**: LoginUseCase, LogoutUseCase
- **Side Effects**: Navigation, error popups, token storage
- **Issues**: None (well-implemented)

### Map
- **Pattern**: BLoC (Route scope)
- **States**: Loading + lat/lng + error
- **Events**: MapStarted, MapStopped, MapLocationUpdated
- **Use Cases**: StoreLocationHistoryUseCase
- **Side Effects**: GPS permission, location streaming, DB storage
- **Issues**: None (well-implemented)

### Meter
- **Pattern**: BLoC (Programmatically created) + StatefulWidget
- **States**: Running, Waiting, Paused + distance + fare + time
- **Events**: Start, Stop, UpdateDistance, TogglePause, SetWaiting, Tick, Reset
- **Use Cases**: StartMeter, StopMeter, CalculateFare
- **Side Effects**: Timer, GPS (in widget), wake lock
- **Issues**: GPS logic should be in BLoC, not widget

### Vehicle Entry
- **Pattern**: StatefulWidget only (No BLoC)
- **States**: _loading (local bool)
- **Events**: None (direct method calls)
- **Use Cases**: FetchAndSaveVehicleUseCase, FetchAndSaveTariffsUseCase
- **Side Effects**: Navigation, error popups
- **Issues**: Should use BLoC for consistency

### Tariff
- **Pattern**: No presentation layer
- **States**: None
- **Events**: None
- **Use Cases**: Multiple (GetAllTariffs, GetTariffById, FetchAndSave...)
- **Issues**: None (domain-only feature)

---

## 🎯 Conclusion

### Current State
The app follows **Clean Architecture** with **BLoC state management** as the primary pattern. Most features are well-structured with clear separation of concerns.

### Key Patterns
1. **BLoC**: Primary state management (Auth, Map, Meter)
2. **StatefulWidget**: Local UI state (forms, controllers)
3. **GetIt**: Dependency injection
4. **Use Cases**: Business logic isolation
5. **Repository Pattern**: Data abstraction

### Next Steps
1. ✅ Move GPS logic from widget to BLoC (Meter feature)
2. ✅ Add VehicleBloc for consistency
3. ✅ Create base state classes for code reuse
4. ✅ Standardize error handling
5. ✅ Remove BuildContext from repository interfaces
6. ✅ Add BLoC unit tests
7. ✅ Document architecture decisions (ADRs)

---

## 📚 Resources

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Best Practices](https://bloclibrary.dev/#/coreconcepts)
- [GetIt Documentation](https://pub.dev/packages/get_it)
