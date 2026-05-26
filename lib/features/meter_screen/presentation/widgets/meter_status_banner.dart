import 'package:flutter/material.dart';

import '../bloc/meter_state.dart';
import '../../../../core/constants/color_constants.dart';

class MeterStatusBanner extends StatelessWidget {
  final MeterState state;

  const MeterStatusBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String status = "VACANT";
    Color color = kGreenColor;
    IconData icon = Icons.check_circle_outline;

    if (state.isRunning) {
      if (state.isWaiting) {
        status = "WAITING";
        color = kOrangeColor;
        icon = Icons.hourglass_empty;
      } else {
        status = "HIRED";
        color = kRedColor;
        icon = Icons.local_taxi;
      }
    } else if (state.endTime != null) {
      status = "PAYMENT";
      color = Colors.blue;
      icon = Icons.payment;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: color.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            status,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }
}
