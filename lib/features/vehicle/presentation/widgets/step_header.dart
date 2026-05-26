import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  const StepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Step $step of $totalSteps",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
      ],
    );
  }
}
