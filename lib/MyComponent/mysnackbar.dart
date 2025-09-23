import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class MySnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    IconData icon;
    Color bgColor;
    Color textColor = Colors.white;

    switch (type) {
      case SnackBarType.success:
        icon = Icons.check_circle;
        bgColor = Colors.green;
        break;
      case SnackBarType.error:
        icon = Icons.error;
        bgColor = Colors.red;
        break;
      case SnackBarType.warning:
        icon = Icons.warning;
        bgColor = Colors.orange;
        break;
      case SnackBarType.info:
        icon = Icons.info;
        bgColor = Colors.blue;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        animation: CurvedAnimation(
          parent: kAlwaysDismissedAnimation,
          curve: Curves.easeOut,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 6,
      ),
    );
  }
}
