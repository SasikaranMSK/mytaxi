import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class MeterActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MeterActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  MeterActionButtonState createState() => MeterActionButtonState();
}

class MeterActionButtonState extends State<MeterActionButton> {
  double _scale = 1.0;

  Future<void> _handleTap() async {
    // small haptic feedback
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // animate press
    setState(() => _scale = 0.95);
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      setState(() => _scale = 1.0);
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          icon: Icon(widget.icon, color: Colors.white),
          label: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            alignment: Alignment.center,
          ),
          onPressed: _handleTap,
        ),
      ),
    );
  }
}
