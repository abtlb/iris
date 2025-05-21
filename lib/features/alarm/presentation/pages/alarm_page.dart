import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/alarm/domain/entities/week_day.dart';
import 'package:vibration/vibration.dart';
import '../../../../main.dart';
import '../../domain/entities/alarm_entity.dart';
import '../bloc/alarm_list/alarm_list_cubit.dart';
import '../../../../../core/util/app_route.dart';

/// Displays list of alarms and allows add, toggle, delete via AlarmListCubit.
class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late final AlarmListCubit _cubit;
  late Timer _ticker;
  late final StreamSubscription _sub;
  //just to force rebuild
  int count = 5;

  @override
  void initState() {
    super.initState();
    // Grab the singleton cubit once and load alarms
    _cubit = GetIt.instance<AlarmListCubit>();
    _cubit.loadAlarms();
    _cubit.ignoreBatteryOptimizations();

    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {count++;});
    });

    _sub = alarmTriggeredBroadcast.listen((message) {
      _cubit.loadAlarms();
    });
  }

  @override
  void dispose() {
    // Dispose if you created it here (or cancel subscriptions)
    _ticker.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimarycolor,
          title: const Text('Your Alarms', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 4,
        ),
        body: BlocBuilder<AlarmListCubit, AlarmListState>(
          builder: (context, state) {
            if (state is AlarmListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AlarmListLoaded) {
              print("Alarms loaded successfuly");
              final alarms = state.alarms;
              if (alarms.isEmpty) {
                return Center(
                  child: Text(
                    'No alarms yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  final formattedTime = DateFormat('hh:mm').format(alarm.time);
                  final formattedPMorAM = DateFormat('a').format(alarm.time);
                  final now = DateTime.now();
                  final diff = alarm.time.difference(now);
                  final days = diff.inDays;
                  final hours = diff.inHours % 24;
                  final minutes = diff.inMinutes % 60;
                  final timeLeft =
                      'in ${days == 0 ? '' : '${days}d '}${hours == 0 ? '' : '${hours}h '}${minutes + 1}m';

                  return Dismissible(
                    key: Key(alarm.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      setState(() {
                        alarms.removeWhere((a) => a.id == alarm.id);
                      });
                      await _cubit.removeAlarm(alarm.id);
                    },

                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: alarm.isEnabled ? 1 : 0.5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final updatedAlarm = await context.push<Alarm>(
                            AppRoute.setAlarmPath,
                            extra: alarm,
                          );
                          if (updatedAlarm != null) {
                            await _cubit.updateAlarm(updatedAlarm);
                          }
                        },
                        child: Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                // Left section
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                              color: alarm.isEnabled
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formattedPMorAM,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: alarm.isEnabled
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (alarm.label.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          alarm.label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: alarm.isEnabled
                                                ? Colors.black87
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                      if (alarm.isEnabled) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.notifications,
                                              size: 16,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              timeLeft,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children:
                                        alarm.repeatDays.map((d) {
                                          return Chip(
                                            label: Text(d.shortName),
                                            backgroundColor:
                                            alarm.isEnabled
                                                ? Colors
                                                .deepPurpleAccent
                                                : Colors.grey[300],
                                            labelStyle: TextStyle(
                                              color: alarm.isEnabled
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right section: toggle
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        alarm.isEnabled
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        size: 80,
                                        color: Colors.deepPurple,
                                      ),
                                      onPressed: () =>
                                          _cubit.toggleAlarm(alarm),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is AlarmListError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: () async {
            final newAlarm = await context.push<Alarm>(AppRoute.setAlarmPath);
            if (newAlarm != null) {
              await context.read<AlarmListCubit>().addAlarm(newAlarm);
              GoRouter.of(context).push(AppRoute.alarmPath);
            }
          },
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}
