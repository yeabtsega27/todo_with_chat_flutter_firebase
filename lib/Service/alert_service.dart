import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

Color _getAlertColor(AlertType type) {
  switch (type) {
    case AlertType.success:
      return Colors.green;
    case AlertType.error:
      return Colors.red;
    case AlertType.warning:
      return Colors.orange;
    case AlertType.info:
    default:
      return Colors.blue;
  }
}

IconData _getAlertIcon(AlertType type) {
  switch (type) {
    case AlertType.success:
      return Icons.check_circle;
    case AlertType.error:
      return Icons.error;
    case AlertType.warning:
      return Icons.warning;
    case AlertType.info:
    default:
      return Icons.info;
  }
}

class AlertService {
  void showAlert(BuildContext context, String message, AlertType type) {
    final color = _getAlertColor(type);
    final icon = _getAlertIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message, style: TextStyle(color: Colors.white))),
          ],
        ),
        duration: const Duration(seconds: 2),
        // action: SnackBarAction(
        //   label: "Undo",
        //   textColor: Colors.white,
        //   onPressed: () {
        //     // Code to undo the change.
        //   },
        // ),
      ),
    );
  }
}
