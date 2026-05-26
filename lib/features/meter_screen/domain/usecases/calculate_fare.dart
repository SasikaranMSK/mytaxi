class CalculateFare {
  /// Minimum distance threshold to consider as "moving" (0.1 km)
  static const double _minMovementThreshold = 0.1;

  /// Calculates the total fare based on distance and waiting time.
  ///
  /// Note: All monetary values (flagFall, rates) are expected in CENTS
  /// and will be converted to dollars for the final fare calculation.
  /// Example: flagFall=360 means $3.60, distanceRate=252 means $2.52/km
  ///
  /// Returns fare rounded to nearest 10 cents (0.10)
  double call({
    required double distance,
    required int waitingTimeInSeconds,
    required double flagFall,
    required double distanceRatePerKm,
    required double distanceRateRange,
    required double distanceRate2PerKm,
    required double waitingTimeRatePerMinute,
  }) {
    final safeDistance = distance < 0 ? 0.0 : distance;
    final safeWaitingSeconds = waitingTimeInSeconds < 0
        ? 0
        : waitingTimeInSeconds;

    // Convert cents to dollars (divide by 100)
    final flagFallDollars = flagFall / 100.0;
    final distanceRateDollars = distanceRatePerKm / 100.0;
    final distanceRate2Dollars = distanceRate2PerKm / 100.0;
    final waitingRateDollars = waitingTimeRatePerMinute / 100.0;

    // Start with flag fall
    double fare = flagFallDollars;

    // Determine if vehicle is moving (distance traveled is significant)
    final isMoving = safeDistance > _minMovementThreshold;

    if (isMoving) {
      // Vehicle is MOVING -> Calculate distance charges only
      double distanceFare = 0;
      if (safeDistance <= distanceRateRange) {
        // Tier 1: Standard rate for first X km
        distanceFare = safeDistance * distanceRateDollars;
      } else {
        // Tier 1 + Tier 2: Split rate for distance over range
        final tier1Fare = distanceRateRange * distanceRateDollars;
        final remainingDistance = safeDistance - distanceRateRange;
        final tier2Fare = remainingDistance * distanceRate2Dollars;
        distanceFare = tier1Fare + tier2Fare;
      }
      fare += distanceFare;
    } else {
      // Vehicle is STATIONARY -> Calculate waiting time charges only
      // Only charge for waiting time if meter has been running for more than 1 minute
      if (safeWaitingSeconds > 60) {
        final waitingMinutes = safeWaitingSeconds / 60.0;
        final waitingFare = waitingMinutes * waitingRateDollars;
        fare += waitingFare;
      }
    }

    // Round to nearest 10 cents (0.10) for professional presentation
    fare = (fare * 10).round() / 10.0;

    return fare;
  }
}
