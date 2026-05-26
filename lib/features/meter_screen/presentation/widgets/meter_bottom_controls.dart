import 'package:flutter/material.dart';

import '../bloc/meter_state.dart';
import '../../../../core/constants/color_constants.dart';
import 'meter_action_button.dart';

class MeterBottomControls extends StatelessWidget {
  final MeterState state;
  final double padding;
  final VoidCallback onStartTrip;
  final VoidCallback onStopTrip;
  final VoidCallback onTogglePause;

  const MeterBottomControls({
    super.key,
    required this.state,
    required this.padding,
    required this.onStartTrip,
    required this.onStopTrip,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: kCardColor,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildButtonsForState()],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsForState() {
    if (state.isRunning) {
      return Row(
        children: [
          Expanded(
            child: MeterActionButton(
              label: state.isPaused ? "RESUME" : "PAUSE",
              icon: state.isPaused ? Icons.play_arrow : Icons.pause,
              color: kOrangeColor,
              onTap: onTogglePause,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MeterActionButton(
              label: "STOP",
              icon: Icons.stop,
              color: kRedColor,
              onTap: onStopTrip,
            ),
          ),
        ],
      );
    }

    return MeterActionButton(
      label: "START TRIP",
      icon: Icons.local_taxi,
      color: kGreenColor,
      onTap: onStartTrip,
    );
  }
}
