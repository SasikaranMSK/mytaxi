import 'package:flutter/material.dart';

bool _isErrorPopupShowing = false;

Future<void> showErrorPopup(
  BuildContext context, {
  required String message,
  String title = 'Error',
}) async {
  if (!context.mounted || _isErrorPopupShowing) return;
  _isErrorPopupShowing = true;

  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A32),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } finally {
    _isErrorPopupShowing = false;
  }
}
