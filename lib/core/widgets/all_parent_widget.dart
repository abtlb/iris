// alarm_dialog_listener.dart
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/alarm/data/%20services/flash_service.dart';
import 'package:untitled3/features/alarm/data/%20services/vibration_flash_service.dart';
import 'package:untitled3/features/alarm/data/%20services/vibration_service.dart';
import 'package:untitled3/main.dart';

import '../../features/alarm/presentation/bloc/alarm_list/alarm_list_cubit.dart';

class AlarmDialogListener extends StatefulWidget {
  final Widget child;
  const AlarmDialogListener({required this.child, super.key});

  @override
  State<AlarmDialogListener> createState() => _AlarmDialogListenerState();
}

class _AlarmDialogListenerState extends State<AlarmDialogListener> {
  late final StreamSubscription _sub;
  int? _currentAlarmId;
  // VibrationService vibrationService = GetIt.instance<VibrationService>();
  // FlashService flashService = GetIt.instance<FlashService>();
  VibrationFlashService vibrationFlashService = GetIt.instance<VibrationFlashService>();

  @override
  void initState() {
    super.initState();
    print("AlarmDialogListener init state called");

    // Listen directly to this port
    _sub = GetIt.instance<Stream<dynamic>>().listen((message) {
      print("=== ALARM DIALOG LISTENER ===");
      print("Received alarm message: $message");
      print("Message type: ${message.runtimeType}");


      try {
        // Handle both String and Map formats for backward compatibility
        String? label;
        int? alarmId;
        int? pattern;

        label = message['label']?.toString();
        alarmId = message['id'] as int?;
        pattern = message['pattern'] as int?;

        vibrationFlashService.start(pattern!);

        // Store the current alarm ID for dismiss
        _currentAlarmId = alarmId;

        // Provide default label if empty or null
        if (label == null || label.isEmpty) {
          label = 'Alarm Notification';
          print("Using default label for empty alarm message");
        }

        print("About to show dialog with label: $label, ID: $alarmId");
        _showAlarmDialog(label, alarmId);
      } catch (e, stackTrace) {
        print("Error processing alarm message: $e");
        print("Stack trace: $stackTrace");
        print("Message was: $message");

        // Show dialog with default label even if there's an error
        _showAlarmDialog('Alarm Notification', null);
      }
    }, onError: (error) {
      print("Error in alarm stream: $error");
    });
  }

  @override
  void dispose() {
    print("AlarmDialogListener disposing");
    _sub.cancel();
    IsolateNameServer.removePortNameMapping('alarm_ui_port');
    super.dispose();
  }

  void _showAlarmDialog(String label, int? alarmId) {
    print("_showAlarmDialog called with label: $label, ID: $alarmId");

    // Try multiple context approaches
    final context = AppRoute.navigatorKey.currentContext ??
        AppRoute.navigatorKey.currentState?.context ??
        AppRoute.navigatorKey.currentState?.overlay?.context;

    if (context == null) {
      print("Error: No valid context available for showing alarm dialog");
      return;
    }

    print("Context found, showing dialog");

    showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'Alarm',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with alarm icon
                Container(
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.red.shade400,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.alarm,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Alarm',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Label content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _dismissAlarm(context, alarmId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.1);
                            }
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.white.withOpacity(0.05);
                            }
                            return Colors.transparent;
                          },
                        ),
                      ),
                      child: const Text(
                        'DISMISS ALARM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              )),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _dismissAlarm(BuildContext context, int? alarmId) {
    print("Dismiss button pressed for alarm ID: $alarmId");

    // Close dialog first
    Navigator.of(context, rootNavigator: true).pop();

    vibrationFlashService.stop();

    // Send dismiss message to the specific alarm's port
    String portName;
    if (alarmId != null) {
      portName = 'alarm_dismiss_port_$alarmId';
    } else {
      // Fallback to old port name for backward compatibility
      portName = 'alarm_dismiss_port';
    }

    SendPort? sendToAlarm = IsolateNameServer.lookupPortByName('dismiss_ui_port');
    if (sendToAlarm != null) {
      try {
        sendToAlarm.send('dismiss');
        print("✅ Sent dismiss message to $portName");
      } catch (e) {
        print("❌ Error sending dismiss message: $e");
      }
    } else {
      print("⚠️ Warning: Could not find port $portName");

      // Try fallback port as well
      if (alarmId != null) {
        final fallbackPort = IsolateNameServer.lookupPortByName('alarm_dismiss_port');
        if (fallbackPort != null) {
          try {
            fallbackPort.send('dismiss');
            print("✅ Sent dismiss message to fallback port");
          } catch (e) {
            print("❌ Error sending to fallback port: $e");
          }
        }
      }
    }

    // Reset current alarm ID
    _currentAlarmId = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}