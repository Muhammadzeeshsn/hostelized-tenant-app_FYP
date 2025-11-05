import 'package:flutter/material.dart';

Future<bool> showOtpDialog(
  BuildContext context, {
  String title = 'Verify OTP',
}) async {
  final c = TextEditingController();
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter 123456'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogCtx, c.text.trim() == '123456'),
              child: const Text('Verify'),
            ),
          ],
        ),
      ) ??
      false;
}
