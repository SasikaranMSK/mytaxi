# Foreground Service Implementation for Meter Screen

## Problem Fixed
The meter screen was only working when the screen was active. When switching to the map tab or when the app ran in the background, the meter would stop working and sometimes reset.

## Solution
Implemented a foreground service using `flutter_foreground_task` that keeps the meter running continuously in the background, even when:
- The app is minimized
- The user switches to another tab (e.g., Map tab)
- The screen is locked
- The app is running in the background

## Key Components Added/Modified

### 1. New File: `foreground_meter_service.dart`
**Location:** `lib/features/meter_screen/data/services/foreground_meter_service.dart`

**Purpose:** Manages the foreground service lifecycle and handles GPS tracking in a background isolate.

**Key Features:**
- Runs GPS tracking in an isolate (separate from main UI thread)
- Tracks distance and waiting time continuously
- Persists state to SharedPreferences
- Sends real-time updates to the main app
- Shows a persistent notification when meter is running
- Handles GPS filtering to avoid jumps and noise 

**Main Classes:**
- `MeterForegroundTaskHandler`: Runs in isolate, handles GPS and calculations
- `ForegroundMeterService`: Singleton service to manage task lifecycle

### 2. Updated: `meter_bloc.dart`
**Changes:**
- Integrated with `ForegroundMeterService`
- Added state persistence using SharedPreferences
- Added new events: `RestoreStateEvent` and `UpdateFromForegroundEvent`
- Automatically starts foreground service when meter starts
- Stops foreground service when meter stops
- Restores state when app comes back from background

**New Methods:**
- `_initializeForegroundService()`: Initializes and checks for existing running service
- `_onRestoreState()`: Restores meter state from SharedPreferences
- `_onUpdateFromForeground()`: Updates state from foreground service data
- `_saveState()`: Persists current state to SharedPreferences

### 3. Updated: `meter_event.dart`
**New Events:**
- `RestoreStateEvent`: Triggers state restoration from SharedPreferences
- `UpdateFromForegroundEvent`: Updates meter with data from foreground service

### 4. Updated: `taximeter_screen.dart`
**Changes:**
- Removed local GPS tracking logic (now handled by foreground service)
- Implemented `WidgetsBindingObserver` for lifecycle management
- Added `didChangeAppLifecycleState()` to restore state when app resumes
- Simplified start/stop trip methods (no more manual GPS management)

### 5. Updated: `main.dart`
**Changes:**
- Added `FlutterForegroundTask.initCommunicationPort()` initialization
- Wrapped MaterialApp with `WithForegroundTask` widget for proper lifecycle handling

## How It Works

### Starting a Trip:
1. User taps "START TRIP"
2. `StartMeterEvent` is dispatched
3. MeterBloc starts the foreground service
4. Foreground service starts GPS tracking in background isolate
5. Service sends distance/waiting time updates to main app
6. MeterBloc receives updates and recalculates fare
7. Persistent notification shows current distance and waiting time

### Background Behavior:
- Foreground service continues running even when app is in background
- GPS tracking continues uninterrupted
- State is saved to SharedPreferences every update
- User sees a notification: "Meter Running - Distance: X km | Waiting: Y min"

### Switching Tabs:
- Meter continues running when switching to Map tab
- State is preserved across tab switches
- When returning to Meter tab, state is restored from SharedPreferences

### App Resume:
- When app comes back from background, `didChangeAppLifecycleState()` is triggered
- `RestoreStateEvent` is dispatched
- State is restored from SharedPreferences
- Foreground service data stream is reconnected
- UI updates with current meter values

### Stopping a Trip:
1. User taps "STOP"
2. `StopMeterEvent` is dispatched
3. Foreground service is stopped
4. Trip is saved to database
5. Payment summary screen is shown

### Collecting Payment:
1. User taps "COLLECT PAYMENT"
2. `ResetMeterEvent` is dispatched
3. Foreground service data is cleared
4. SharedPreferences state is cleared
5. Meter returns to "VACANT" state

## State Persistence Keys

Stored in SharedPreferences:
- `meter_is_running`: Boolean indicating if meter is active
- `meter_start_time`: Timestamp when trip started
- `meter_distance`: Current distance in kilometers
- `meter_waiting_time`: Current waiting time in seconds
- `meter_last_update`: Last update timestamp
- `foreground_service_running`: Boolean indicating if foreground service is active

## Permissions

Already configured in AndroidManifest.xml:
- `FOREGROUND_SERVICE`: Allows foreground service
- `FOREGROUND_SERVICE_LOCATION`: Allows location tracking in foreground service
- `ACCESS_FINE_LOCATION`: GPS access
- `ACCESS_COARSE_LOCATION`: Network-based location

## Notification

When meter is running, user sees a persistent notification:
- **Title:** "Meter Running"
- **Text:** "Distance: X.XX km | Waiting: Y.Y min"
- **Icon:** Taxi icon (ic_taxi)
- **Priority:** LOW (doesn't disturb user)
- **Updates:** Every 5 seconds

## Testing Scenarios

### ✅ Test 1: Background Operation
1. Start a trip
2. Press home button to minimize app
3. Wait 1-2 minutes
4. Return to app
5. **Expected:** Distance and time should have increased

### ✅ Test 2: Tab Switching
1. Start a trip
2. Switch to Map tab
3. Wait 1 minute
4. Return to Fare tab
5. **Expected:** Meter continues running with updated values

### ✅ Test 3: App Kill & Restart
1. Start a trip
2. Force close the app
3. Reopen the app
4. **Expected:** Meter state is restored and continues running

### ✅ Test 4: Screen Lock
1. Start a trip
2. Lock the device
3. Wait 1 minute
4. Unlock and open app
5. **Expected:** Meter continues running with updated values

## Benefits

1. **Continuous Tracking**: Meter never stops or resets when switching tabs or going to background
2. **Battery Efficient**: Uses foreground service best practices with optimized GPS settings
3. **State Persistence**: Trip data is never lost, even if app crashes
4. **User Awareness**: Persistent notification keeps user informed
5. **Accurate Tracking**: GPS filtering prevents jumps and noise in distance calculations
6. **Reliable**: Runs in separate isolate, independent of main UI thread

## Notes

- The foreground service will continue running even if the app is killed, until explicitly stopped
- Service is automatically started when meter starts and stopped when meter stops
- All state is persisted to handle app crashes or force closes
- GPS updates occur every 5 seconds in foreground service
- Distance updates are sent to main app immediately when significant movement detected
- Waiting time is tracked automatically when vehicle is idle for 5+ seconds
