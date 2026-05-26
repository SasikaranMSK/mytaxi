import 'package:flutter/material.dart';

class MapRecenterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MapRecenterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "recenter_btn",
      backgroundColor: Colors.black87,
      onPressed: onPressed,
      child: const Icon(Icons.gps_fixed, color: Colors.white),
    );
  }
}
