import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/main.dart';

import '../../features/alarm/presentation/bloc/alarm_list/alarm_list_cubit.dart'; // for uiPort & navigatorKey

/// This widget “listens” for alarm events and calls
/// showGeneralDialog on its own BuildContext.
class AlarmDialogListener extends StatefulWidget {
  final Widget child;
  const AlarmDialogListener({required this.child, super.key});

  @override
  State<AlarmDialogListener> createState() => _AlarmDialogListenerState();
}

class _AlarmDialogListenerState extends State<AlarmDialogListener> {


  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    // subscribe to the same uiPort you registered in main()
    print("init state called");
    _sub = alarmTriggeredBroadcast.listen((message) {
      final label = message as String;
      _showAlarmDialog(label);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _showAlarmDialog(String label) {
    showGeneralDialog(//todo make it pretty
      context: AppRoute.navigatorKey.currentState!.overlay!.context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'Alarm',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(AppRoute.navigatorKey.currentState!.overlay!.context).size.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // … your header & content …
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(label, textAlign: TextAlign.center),
                ),
                const Divider(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            AppRoute.navigatorKey.currentState!.overlay!.context,
                            rootNavigator: true,
                          ).pop();
                          final sendToAlarm = IsolateNameServer.lookupPortByName('alarm_dismiss_port');
                          sendToAlarm?.send('dismiss');
                        },
                        child: const Text('DISMISS'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
