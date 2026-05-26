import 'package:flutter/foundation.dart';

class LoggingUtil {
  static void logDebug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }

  static void logError(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('ERROR: $message');
    }
  }
}
