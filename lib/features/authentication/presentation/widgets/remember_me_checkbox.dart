import 'package:flutter/material.dart';

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: const Color(0xFF4CAF50),
        ),
        const Text("Remember Me", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
