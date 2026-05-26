import 'package:flutter/material.dart';

import '../bloc/meter_state.dart';
import 'meter_stat_card.dart';

class MeterStatsGrid extends StatelessWidget {
  final MeterState state;
  final bool isSmall;

  const MeterStatsGrid({
    super.key,
    required this.state,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final duration = state.startTime == null
        ? Duration.zero
        : (state.isRunning
              ? DateTime.now().difference(state.startTime!)
              : (state.endTime ?? DateTime.now()).difference(state.startTime!));

    return Row(
      children: [
        Expanded(
          child: MeterStatCard(
            label: "DISTANCE",
            value: state.distance.toStringAsFixed(2),
            unit: "km",
            isSmall: isSmall,
          ),
        ),
        SizedBox(width: isSmall ? 8 : 16),
        Expanded(
          child: MeterStatCard(
            label: "TIME",
            value: _formatDuration(duration),
            unit: "hh:mm:ss",
            isSmall: isSmall,
          ),
        ),
        SizedBox(width: isSmall ? 8 : 16),
        Expanded(
          child: MeterStatCard(
            label: "WAIT",
            value: _formatMinutesSeconds(state.waitingTime),
            unit: "mm:ss",
            isSmall: isSmall,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatMinutesSeconds(int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${twoDigits(minutes)}:${twoDigits(remainingSeconds)}";
  }
}
