# Driver Dashboard Feature

## Overview

The Driver Dashboard feature provides a comprehensive interface for drivers to view, manage, and accept assigned jobs after successful login and vehicle verification. This feature integrates with multiple backend APIs to fetch jobs, validate vehicles, and manage driver status.

## Navigation Flow

1. **Login** → `LoginPage` (after successful authentication)
2. **Vehicle Entry** → `VehicleEntryScreen` (enter vehicle number)
3. **Dashboard** → `DashboardPage` (view and manage jobs)

After the driver successfully enters a valid vehicle number, they are automatically routed to the Dashboard where they can:
- View all assigned jobs
- Filter jobs by status (All, Pending, Assigned, Accepted, In Progress)
- Accept or reject jobs
- Start work (activates vehicle and sets driver status)
- View driver status (Online, On Duty, Vehicle Activated)

## Architecture

The feature follows **Clean Architecture** principles with three layers:

### Domain Layer
- **Entities**: `JobEntity`, `DriverStatusEntity`, `VehicleValidationEntity`
- **Repositories**: `DashboardRepository` (abstract interface)
- **Use Cases**:
  - `GetDriverJobsUseCase` - Fetch all driver jobs
  - `AcceptJobUseCase` - Accept a specific job
  - `StartWorkUseCase` - Complete work initialization (validate, activate, set status)
  - `GetDriverStatusUseCase` - Get current driver status

### Data Layer
- **Models**: `JobModel`, `DriverStatusModel`, `VehicleValidationModel`
- **Data Sources**: `DashboardRemoteDataSource` - API communication
- **Repositories**: `DashboardRepositoryImpl` - Implementation of domain repository

### Presentation Layer
- **BLoC**: `DashboardBloc` - State management using flutter_bloc
- **Pages**: `DashboardPage` - Main dashboard UI
- **Widgets**:
  - `JobCard` - Individual job display with action buttons
  - `DriverStatusIndicator` - Shows driver's online/duty/vehicle status

## API Integration

### Feature 1: Receive List of Assigned Booking Details

| Method | Endpoint | Purpose | Request Body |
|--------|----------|---------|--------------|
| GET | `/taxis-api/api/Driver/DriverJobs` | All jobs for logged-in driver | N/A |
| GET | `/taxis-api/api/Driver/DriverJobByStatus` | Filter jobs by status | Query: `?status=pending` |
| GET | `/taxis-api/api/Driver/Jobs` | Alternate job list endpoint | N/A |
| POST | `/taxis-api/api/Jobs/GetNewJobs` | Poll for newly assigned jobs | See below |
| POST | `/taxis-api/api/DeviceJobs/{macAddress}/GetAllBySearch` | Search jobs for device | See below |
| GET | `/taxis-api/api/DeviceJobs/{Id}` | Get full details of single job | N/A |

**GetNewJobs Request:**
```json
{
  "macAddress": "string",
  "driverId": 0,
  "vehicleNo": "string",
  "radius": 0,
  "vehicleTypeId": 0
}
```

**GetAllBySearch Request:**
```json
{
  "pageNumber": 0,
  "pageSize": 20,
  "search": "string",
  "searchColumn": "string",
  "sortColumnName": "string",
  "sortDirection": "string"
}
```

### Feature 2: Pick Assigned Task & Verify Vehicle

| Method | Endpoint | Purpose | Request Body |
|--------|----------|---------|--------------|
| POST | `/taxis-api/api/DeviceJobs/Accept` | Accept assigned job | See below |
| GET | `/taxis-api/api/Validations/ValidateDriveVehicles` | Verify driver authorization | N/A |
| GET | `/taxis-api/api/Document/CheckVehicleDocumentsValidity` | Check vehicle documents | N/A |
| GET | `/taxis-api/api/Driver/ActivateVehicle` | Activate vehicle for duty | N/A |
| GET | `/taxis-api/api/DriverStatus/Online` | Set driver status → Online | N/A |
| GET | `/taxis-api/api/DriverStatus/OnDuty` | Set driver status → On Duty | N/A |
| GET | `/taxis-api/api/DriverDutyTimes/{DriverId}/latest-shift` | Check shift/duty time | N/A |

**Accept Job Request:**
```json
{
  "jobId": 0,
  "macAddress": "string",
  "vehicleId": 0
}
```

## State Management

The dashboard uses **BLoC pattern** for state management:

### Events
- `LoadDashboard` - Initial load of dashboard data
- `RefreshJobs` - Refresh job list
- `AcceptJob` - Accept a specific job
- `RejectJob` - Reject a job
- `StartWork` - Initialize work session
- `FilterJobsByStatus` - Filter jobs by status

### States
- `DashboardInitial` - Initial state
- `DashboardLoading` - Loading data
- `DashboardLoaded` - Data loaded successfully (contains jobs and driver status)
- `DashboardError` - Error occurred
- `WorkStarted` - Work session started successfully
- `WorkStartError` - Error starting work

## UI Features

### Driver Status Indicator
Displays three status indicators:
1. **Online** - Driver is connected and available
2. **On Duty** - Driver is actively working
3. **Vehicle Activated** - Vehicle is verified and activated

When not on duty, shows a "START WORK" button that:
1. Validates driver-vehicle authorization
2. Checks vehicle document validity
3. Activates vehicle
4. Sets driver online
5. Sets driver on duty

### Job Card
Each job displays:
- Job number and status badge
- Priority indicator (if applicable)
- Pickup date/time
- Pickup and dropoff addresses
- Customer name and phone
- Estimated fare and distance
- Special instructions (if any)
- Accept/Reject action buttons (for pending/assigned jobs)

### Job Filtering
Filter jobs by status:
- All
- Pending
- Assigned
- Accepted
- In Progress

### Pull to Refresh
The job list supports pull-to-refresh for manual updates.

## Dependency Injection

All dependencies are registered in `dashboard_injection.dart` and initialized in the main `injection_container.dart`:

```dart
void initDashboardDependencies() {
  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDriverJobsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptJobUseCase(sl()));
  sl.registerLazySingleton(() => StartWorkUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverStatusUseCase(sl()));

  // BLoC
  sl.registerFactory(() => DashboardBloc(...));
}
```

## Error Handling

The dashboard handles various error scenarios:
- **No vehicle information** - Shows error popup
- **API failures** - Shows error message with details
- **Invalid documents** - Prevents work start and shows reason
- **Unauthorized driver** - Prevents vehicle activation

## Testing

To test the dashboard feature:

1. **Login** with valid credentials
2. **Enter vehicle number** that exists in the system
3. **Dashboard loads** with jobs (may be empty initially)
4. **Start Work** to activate vehicle and set status
5. **Accept Jobs** from the available list
6. **Filter Jobs** to view by status
7. **Pull to refresh** to get latest jobs

## Future Enhancements

Potential improvements:
1. Real-time job notifications using WebSocket or FCM
2. Auto-refresh jobs at intervals
3. Job details page with map view
4. Job history and earnings tracking
5. In-app navigation to pickup/dropoff locations
6. Chat with customer
7. Rating system
8. Offline mode with local caching

## File Structure

```
lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   └── dashboard_remote_data_source.dart
│   ├── models/
│   │   ├── job_model.dart
│   │   ├── driver_status_model.dart
│   │   └── vehicle_validation_model.dart
│   └── repositories/
│       └── dashboard_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── job_entity.dart
│   │   ├── driver_status_entity.dart
│   │   └── vehicle_validation_entity.dart
│   ├── repositories/
│   │   └── dashboard_repository.dart
│   └── usecases/
│       ├── get_driver_jobs_usecase.dart
│       ├── accept_job_usecase.dart
│       ├── start_work_usecase.dart
│       └── get_driver_status_usecase.dart
├── presentation/
│   ├── bloc/
│   │   ├── dashboard_bloc.dart
│   │   ├── dashboard_event.dart
│   │   └── dashboard_state.dart
│   ├── pages/
│   │   └── dashboard_page.dart
│   └── widgets/
│       ├── job_card.dart
│       └── driver_status_indicator.dart
└── dashboard_injection.dart
```

## Notes

- **MAC Address**: The current implementation uses a placeholder `DEVICE_MAC_ADDRESS`. This should be replaced with the actual device MAC address retrieval logic.
- **Authentication**: All API calls include the Bearer token from `TokenStorage` via Dio interceptor.
- **Base URL**: Configured in `ApiConfig.baseUrl` as `https://mytaxis.softclient.com.au`
- **Intl Package**: Added for date/time formatting in the job cards.

## Support

For issues or questions about the dashboard feature, refer to:
- BLoC pattern documentation: https://bloclibrary.dev/
- Clean Architecture principles
- API documentation from backend team
