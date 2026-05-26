import 'package:flutter/material.dart';

import '../../../../core/constants/color_constants.dart';

class MeterStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isSmall;

  const MeterStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (label.toLowerCase()) {
      case 'distance':
        icon = Icons.map;
        break;
      case 'time':
        icon = Icons.access_time;
        break;
      case 'wait':
        icon = Icons.hourglass_empty;
        break;
      default:
        icon = Icons.info_outline;
    }

    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kAccentColor, size: isSmall ? 20 : 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: textTheme.bodySmall?.copyWith(
              color: kSecondaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: isSmall ? 4 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            unit,
            style: textTheme.labelSmall?.copyWith(
              color: kSecondaryText.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
