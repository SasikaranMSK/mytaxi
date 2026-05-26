import 'package:flutter/material.dart';

import '../../../../core/constants/color_constants.dart';

class MeterFareDisplay extends StatelessWidget {
  final double totalFare;
  final bool isSmall;

  const MeterFareDisplay({
    super.key,
    required this.totalFare,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 28, horizontal: 24),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "TOTAL FARE",
            style: textTheme.labelSmall?.copyWith(
              color: kSecondaryText,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$",
                style: textTheme.titleMedium?.copyWith(
                  color: kSecondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  totalFare.toStringAsFixed(2),
                  style: textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontSize: isSmall ? 48 : 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
