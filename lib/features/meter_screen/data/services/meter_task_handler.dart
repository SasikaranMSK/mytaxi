import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

class MeterTaskHandler extends TaskHandler {
  Position? _lastPosition;
  SendPort? _sendPort;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // NOTE: Permissions should be handled in UI before starting the task.
    _lastPosition = null;
    _sendPort = null;
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        _sendPort?.send(distance);
      }

      _lastPosition = position;
    } catch (_) {
      // Swallow errors to keep the foreground task running.
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _lastPosition = null;
    _sendPort = null;
  }

  @override
  void onReceiveData(Object data) {
    // Expected: SendPort from the main isolate.
    if (data is SendPort) {
      _sendPort = data;
    }
  }
}
