import 'package:flutter/material.dart';
import 'package:untitled3/core/util/notification_helper.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_callback_service.dart'; // Update the path if needed

class EmergencyAlertDialog extends StatelessWidget {
  final String reason;

  const EmergencyAlertDialog({
    Key? key,
    required this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active,
                size: 64, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'Alert!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reason,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            // const SizedBox(height: 20),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8),
            //   child: LinearProgressIndicator(
            //     value: confidenceLevel,
            //     minHeight: 10,
            //     color: Colors.red,
            //     backgroundColor: Colors.red[100],
            //   ),
            // ),
            const SizedBox(height: 12),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 16),
            // Test Vibration Button (made smaller for popup)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("📳 Vibration-only notification triggered");
                  NotificationHelper.show(
                    title: "Test Notification",
                    body: "This is a test vibration-only alert.",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Test Vibration Alert',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to show the popup
  static Future<void> show(
      BuildContext context, {
        required String reason,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        // NotificationHelper.show(
        //   title: "Alarm triggered",
        //   body: 'Alarm triggered because $reason',
        // );
        return const SizedBox.shrink();
      },
    );
  }
}