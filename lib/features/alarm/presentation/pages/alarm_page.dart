import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

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
import '../../../../core/widgets/all_parent_widget.dart';
import '../../../../main.dart';
import '../../domain/entities/alarm_entity.dart';
import '../bloc/alarm_list/alarm_list_cubit.dart';
import '../../../../../core/util/app_route.dart';

/// Modern, accessible alarm page with improved design and user experience
class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with TickerProviderStateMixin {
  late final AlarmListCubit _cubit;
  late Timer _ticker;
  late final StreamSubscription _sub;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  int count = 5;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<AlarmListCubit>();
    _cubit.loadAlarms();
    _cubit.ignoreBatteryOptimizations();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {count++;});
    });

    _sub = GetIt.instance<Stream<dynamic>>(instanceName: 'dismissStream').listen((message) {
      _cubit.loadAlarms();
    });

    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 500), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _fabAnimationController.dispose();
    _sub.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor], // Adjust gradient as needed
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Alarms',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          body: BlocBuilder<AlarmListCubit, AlarmListState>(
            builder: (context, state) {
              if (state is AlarmListLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading alarms...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is AlarmListLoaded) {
                final alarms = state.alarms;
                if (alarms.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildAlarmList(context, alarms);
              } else if (state is AlarmListError) {
                return _buildErrorState(context, state.message);
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondaryColor,
              onPressed: () async {
                final newAlarm = await context.push<Alarm>(AppRoute.setAlarmPath);
                if (newAlarm != null) {
                  await _cubit.addAlarm(newAlarm);
                }
                await _cubit.loadAlarms();
              },
              icon: const Icon(Icons.add, size: 24),
              label: Text(
                'Add Alarm',
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: kFont),
              ),
              tooltip: 'Add new alarm',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_add_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No alarms set',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first alarm',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => _cubit.loadAlarms(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmList(BuildContext context, List<Alarm> alarms) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return _buildAlarmCard(context, alarm, index);
      },
    );
  }

  Widget _buildAlarmCard(BuildContext context, Alarm alarm, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedTime = DateFormat('HH:mm').format(alarm.time);
    final formattedPeriod = DateFormat('a').format(alarm.time);
    final timeUntilAlarm = _calculateTimeUntilAlarm(alarm.time);

    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: colorScheme.onErrorContainer,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        await _cubit.removeAlarm(alarm.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Alarm deleted'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final updatedAlarm = await context.push<Alarm>(
                  AppRoute.setAlarmPath,
                  extra: alarm,
                );
                if (updatedAlarm != null) {
                  await _cubit.updateAlarm(updatedAlarm);
                  await _cubit.loadAlarms();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: alarm.isEnabled
                      ? colorScheme.surfaceVariant.withOpacity(0.3)
                      : colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: alarm.isEnabled
                        ? colorScheme.outline.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Time section
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time display
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formattedTime,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: alarm.isEnabled
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.4),
                                ),
                                semanticsLabel: 'Alarm time $formattedTime $formattedPeriod',
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedPeriod,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: alarm.isEnabled
                                      ? colorScheme.onSurface.withOpacity(0.7)
                                      : colorScheme.onSurface.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),

                          // Label
                          if (alarm.label.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              alarm.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: alarm.isEnabled
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.4),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Time until alarm
                          if (alarm.isEnabled && timeUntilAlarm.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kSecondaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: kTextPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeUntilAlarm,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Repeat days
                          if (alarm.repeatDays.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: alarm.repeatDays.map((day) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alarm.isEnabled
                                        ? kSecondaryColor
                                        : colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    day.shortName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: alarm.isEnabled
                                          ? kPrimaryColor
                                          : colorScheme.onSurface.withOpacity(0.4),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Toggle switch
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Switch.adaptive(
                        value: alarm.isEnabled,
                        onChanged: (value) {
                          _cubit.toggleAlarm(alarm);
                          // Haptic feedback
                          if (alarm.isEnabled) {
                            // Light impact for turning off
                          } else {
                            // Medium impact for turning on
                          }
                        },
                        activeColor: kPrimaryColor,
                        activeTrackColor: kSecondaryColor,
                        inactiveThumbColor: colorScheme.outline,
                        inactiveTrackColor: colorScheme.surfaceVariant,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _calculateTimeUntilAlarm(DateTime alarmTime) {
    final now = DateTime.now();
    final diff = alarmTime.difference(now);

    if (diff.isNegative) return '';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return 'in ${days}d ${hours}h ${minutes + 1}m';
    } else if (hours > 0) {
      return 'in ${hours}h ${minutes + 1}m';
    } else {
      return 'in ${minutes + 1}m';
    }
  }
}