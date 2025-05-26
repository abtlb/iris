import 'package:flutter/material.dart';
import 'package:untitled3/core/util/notification_helper.dart'; // Update the path if needed

class EmergencyAlertPage extends StatelessWidget {
  final String detectedSound;
  final double confidenceLevel;

  const EmergencyAlertPage({
    Key? key,
    required this.detectedSound,
    required this.confidenceLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
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
                  '$detectedSound Detected',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: confidenceLevel,
                    minHeight: 10,
                    color: Colors.red,
                    backgroundColor: Colors.red[100],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The system has detected a $detectedSound sound\n'
                      'with ${(confidenceLevel * 100).toStringAsFixed(0)}% confidence.',
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Add emergency call functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Emergency Call',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ✅ Vibration Test Button
                ElevatedButton(
                  onPressed: () {
                    print("📳 Vibration-only notification triggered");
                    NotificationHelper.show(
                      title: "Test Notification",
                      body: "This is a test vibration-only alert.",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Test Vibration Alert',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}