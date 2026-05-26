import '../entities/tariff_entity.dart';

/// Use case to select the appropriate active tariff based on current date/time
class SelectActiveTariffUseCase {
  /// Selects the most appropriate tariff from a list based on current date/time
  ///
  /// Priority:
  /// 1. Public holiday tariffs (if today is a public holiday)
  /// 2. Time and day-specific tariffs
  /// 3. Default/fallback tariff
  TariffEntity call(
      List<TariffEntity> tariffs, {
        DateTime? currentTime,
        bool isPublicHoliday = false,
      }) {
    if (tariffs.isEmpty) {
      throw Exception('No tariffs available');
    }

    final now = currentTime ?? DateTime.now();
    final dayOfWeek = now.weekday; // Monday = 1, Sunday = 7
    final timeOfDay = TimeOfDay.fromDateTime(now);

    // Filter active tariffs
    final activeTariffs = tariffs.where((t) => t.active).toList();
    if (activeTariffs.isEmpty) {
      throw Exception('No active tariffs available');
    }

    // If public holiday, try to find public holiday tariff
    if (isPublicHoliday) {
      final publicHolidayTariff = activeTariffs.firstWhere(
            (t) =>
        t.publicHolidays &&
            _isWithinTimeRange(t, timeOfDay) &&
            _isWithinDayRange(t, dayOfWeek),
        orElse: () => activeTariffs.first,
      );
      return publicHolidayTariff;
    }

    // Find tariff matching current day and time
    final matchingTariffs = activeTariffs.where((t) {
      return _isWithinDayRange(t, dayOfWeek) &&
          _isWithinTimeRange(t, timeOfDay);
    }).toList();

    if (matchingTariffs.isNotEmpty) {
      // Return the most specific tariff (highest flag fall usually means more specific rate)
      matchingTariffs.sort((a, b) => b.flagFall.compareTo(a.flagFall));
      return matchingTariffs.first;
    }

    // Fallback to first active tariff
    return activeTariffs.first;
  }

  bool _isWithinDayRange(TariffEntity tariff, int currentDay) {
    // fromDay and toDay are 1-7 (Monday to Sunday)
    // Handle wrap-around (e.g., Friday to Sunday: 5 to 7, or Friday to Monday: 5 to 1)
    if (tariff.fromDay <= tariff.toDay) {
      return currentDay >= tariff.fromDay && currentDay <= tariff.toDay;
    } else {
      // Wrap around case
      return currentDay >= tariff.fromDay || currentDay <= tariff.toDay;
    }
  }

  bool _isWithinTimeRange(TariffEntity tariff, TimeOfDay currentTime) {
    final start = _parseTime(tariff.startTime);
    final end = _parseTime(tariff.endTime);

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    // Handle wrap-around (e.g., 22:00 to 05:59)
    if (start <= end) {
      return currentMinutes >= start && currentMinutes <= end;
    } else {
      // Wrap around midnight
      return currentMinutes >= start || currentMinutes <= end;
    }
  }

  int _parseTime(String timeStr) {
    // Expected format: "HH:mm am" or "HH:mm" (24-hour)
    try {
      final cleaned = timeStr.trim().toLowerCase();
      final parts = cleaned.split(':');

      if (parts.length < 2) return 0;

      int hour = int.parse(parts[0]);
      final minutePart = parts[1].split(' ');
      int minute = int.parse(minutePart[0]);

      // Handle AM/PM if present
      if (minutePart.length > 1) {
        final meridiem = minutePart[1];
        if (meridiem == 'pm' && hour != 12) {
          hour += 12;
        } else if (meridiem == 'am' && hour == 12) {
          hour = 0;
        }
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
