import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_callback_service.dart';
import 'package:untitled3/features/sound_detection/presentation/bloc/sound_monitor_bloc.dart';
import 'package:untitled3/features/sound_detection/presentation/bloc/sound_monitor_event.dart';
import 'package:untitled3/features/sound_detection/presentation/bloc/sound_monitor_states.dart';
import '../../domain/entities/sound_detection_settings.dart';
import '../widgets/emergency_alert_dialog.dart';
import 'emergency_alert_page.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:go_router/go_router.dart';

class SoundAlertPage extends StatefulWidget {
  @override
  _SoundAlertPageState createState() => _SoundAlertPageState();
}

class _SoundAlertPageState extends State<SoundAlertPage> with TickerProviderStateMixin  {
  double loudNoiseThreshold = 69;
  double _originalLoudNoiseThreshold = 69;
  bool alarmTriggered = false;

  late AnimationController _pulseController;
  late AnimationController _cardAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardAnimation;
  late SoundMonitorBloc _bloc;
  List<String> _cachedDetectedEvents = [];


  Map<String, bool> soundTriggers = {
    "Smoke Alarm": false,
    "Fire Alarm": false,
    "Doorbell": true,
    "Siren": false,
    "Buzzer": false,
    "Beep": false,
    "Baby cry": false,
  };

  Map<String, bool> _originalSoundTriggers = {};

  bool isLoudNoiseEnabled = true;
  bool _originalIsLoudNoiseEnabled = true;

  // Track if settings have been modified
  bool get _hasUnsavedChanges {
    return loudNoiseThreshold != _originalLoudNoiseThreshold ||
        isLoudNoiseEnabled != _originalIsLoudNoiseEnabled ||
        !_mapsEqual(soundTriggers, _originalSoundTriggers);
  }

  bool _mapsEqual(Map<String, bool> map1, Map<String, bool> map2) {
    if (map1.length != map2.length) return false;
    for (String key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  void _saveOriginalSettings() {
    _originalLoudNoiseThreshold = loudNoiseThreshold;
    _originalIsLoudNoiseEnabled = isLoudNoiseEnabled;
    _originalSoundTriggers = Map<String, bool>.from(soundTriggers);
  }

  void _onSaveSettings() {
    // Get list of enabled sound triggers
    List<String> enabledTriggers = [];

    // Add enabled sound triggers
    soundTriggers.entries.where((entry) => entry.value).forEach((entry) {
      enabledTriggers.add(entry.key);
    });

    final settings = SoundDetectionSettings(
      dbThreshold: loudNoiseThreshold,
      triggeringSounds: enabledTriggers,
      isLoudNoiseEnabled: isLoudNoiseEnabled,
    );

    _bloc.add(SaveSettingsEvent(settings: settings));

    // Update original settings to reflect saved state
    _saveOriginalSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: kSuccessColor,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );

    _saveOriginalSettings();

    // Animate cards entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  TextStyle get headingStyle => TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.indigo[900]);
  TextStyle get subheadingStyle => TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]);
  TextStyle get labelStyle => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider<SoundMonitorBloc>(
      create: (_) {
        _bloc = GetIt.instance<SoundMonitorBloc>();
        _bloc.add(const LoadSettingsEvent());
        _bloc.add(const StartMonitoringEvent());
        return _bloc;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Sound Guard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            // actions: [
            //   // TextButton(
            //   //   onPressed: () {
            //   //     Navigator.push(
            //   //       context,
            //   //       MaterialPageRoute(
            //   //         builder: (_) => EmergencyAlertPage(
            //   //           detectedSound: 'Doorbell',
            //   //           confidenceLevel: 0.77,
            //   //         ),
            //   //       ),
            //   //     );
            //   //   },
            //   //   child: Text(
            //   //     "Next",
            //   //     style: TextStyle(
            //   //       color: colorScheme.primary,
            //   //       fontWeight: FontWeight.w600,
            //   //       fontFamily: kFont,
            //   //     ),
            //   //   ),
            //   // ),
            // ],
          ),
          body: BlocConsumer<SoundMonitorBloc, SoundMonitorState>(
            listener: (context, state) {
              if (state is SoundMonitorError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }

              if (state is SettingsUpdated) {
                setState(() {
                  loudNoiseThreshold = state.settings.dbThreshold;
                  isLoudNoiseEnabled = state.settings.isLoudNoiseEnabled;

                  for (var entry in soundTriggers.entries) {
                    soundTriggers[entry.key] = state.settings.triggeringSounds.contains(entry.key);
                  }

                  _saveOriginalSettings();
                });
              }

              if (state is AlarmTriggered) {
                setState(() {
                  alarmTriggered = true;
                });

                alarmCallback(69, {'label': state.reason, 'pattern': 1}).then((result) {
                  _bloc.add(const DismissAlarmEvent());
                });
              }

              if (state is SoundMonitorRunning) {
                _updateDetectedEvents(state.soundEvents);
              }
            },
            builder: (context, state) {
              double decibelLevel = 0;

              if (state is SoundMonitorRunning) {
                decibelLevel = state.dbLevel;
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _buildDecibelGauge(context, decibelLevel),
                  const SizedBox(height: 16),
                  _buildSoundDetection(context, state, _cachedDetectedEvents),
                  const SizedBox(height: 16),
                  _buildLoudNoiseTrigger(context),
                  const SizedBox(height: 16),
                  _buildSoundTriggers(context),
                  const SizedBox(height: 16),
                  _buildControlButtons(context, state),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDecibelGauge(BuildContext context, double decibelLevel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Decibel Level',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 120,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 60, color: kBlueLight),
                      GaugeRange(startValue: 60, endValue: 90, color: kBlueMedium),
                      GaugeRange(startValue: 90, endValue: 120, color: kBlueDark),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: decibelLevel,
                        needleColor: colorScheme.primary,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(decibelLevel.isInfinite || decibelLevel.isNaN)? 0 : decibelLevel.toInt()} dB',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor,
                              fontFamily: kFont,
                            ),
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundDetection(BuildContext context, SoundMonitorState state, List<String> detectedEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isListening = state is SoundMonitorRunning;
    bool isLoading = state is SoundMonitorLoading;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isListening ? kSecondaryColor : colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hearing,
                    color: isListening ? kPrimaryColor : colorScheme.onSurface.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sound Detection',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontFamily: kFont,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoading
                            ? "Starting monitoring..."
                            : isListening
                            ? "Listening for sounds..."
                            : "Sound monitoring stopped",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                else if (isListening)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Sound wave visualization
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(15, (index) {
                  final height = isListening
                      ? (20 + (index % 3) * 15).toDouble()
                      : 8.0;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    width: 4,
                    height: height,
                    decoration: BoxDecoration(
                      color: isListening
                          ? kPrimaryColor
                          : colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            if (detectedEvents.isNotEmpty) ...[
              Text(
                'Currently Detected:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detectedEvents.map((event) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                ).toList(),
              ),
            ] else ...[
              Text(
                isListening ? 'No specific sounds detected' : 'Monitoring stopped',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _hasUnsavedChanges ? _onSaveSettings : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _hasUnsavedChanges
                        ? kSecondaryColor.withOpacity(0.3)
                        : colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasUnsavedChanges
                          ? kPrimaryColor.withOpacity(0.3)
                          : colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _hasUnsavedChanges
                              ? kSecondaryColor
                              : colorScheme.surfaceVariant.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.save,
                          color: _hasUnsavedChanges
                              ? kPrimaryColor
                              : colorScheme.onSurface.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Save Changes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _hasUnsavedChanges
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_hasUnsavedChanges) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "You have unsaved changes",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, SoundMonitorState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    bool isRunning = state is SoundMonitorRunning;
    bool isLoading = state is SoundMonitorLoading;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Control',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildControlButton(
                    context: context,
                    icon: Icons.play_arrow,
                    label: 'Start',
                    color: kBlueLight,
                    isEnabled: !(isRunning || isLoading),
                    onTap: () => _bloc.add(const StartMonitoringEvent()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildControlButton(
                    context: context,
                    icon: Icons.stop,
                    label: 'Stop',
                    color: kBlueDark,
                    isEnabled: (isRunning || isLoading),
                    onTap: () => _bloc.add(const StopMonitoringEvent()),
                  ),
                ),
                // const SizedBox(width: 12),
                // Expanded(
                //   child: _buildControlButton(
                //     context: context,
                //     icon: Icons.refresh,
                //     label: 'Restart',
                //     color: Colors.orange,
                //     isEnabled: true,
                //     onTap: () => _bloc.add(const RestartMonitoringEvent()),
                //   ),
                // ),
              ],
            ),
            // if (alarmTriggered) ...[
            //   const SizedBox(height: 16),
            //   Material(
            //     color: Colors.transparent,
            //     child: InkWell(
            //       borderRadius: BorderRadius.circular(16),
            //       onTap: () {
            //         setState(() {
            //           alarmTriggered = false;
            //         });
            //         _bloc.add(const DismissAlarmEvent());
            //       },
            //       child: AnimatedContainer(
            //         duration: const Duration(milliseconds: 200),
            //         width: double.infinity,
            //         padding: const EdgeInsets.all(16),
            //         decoration: BoxDecoration(
            //           color: Colors.green.withOpacity(0.2),
            //           borderRadius: BorderRadius.circular(16),
            //           border: Border.all(
            //             color: Colors.green.withOpacity(0.3),
            //             width: 1,
            //           ),
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Container(
            //               padding: const EdgeInsets.all(8),
            //               decoration: BoxDecoration(
            //                 color: Colors.green.withOpacity(0.3),
            //                 shape: BoxShape.circle,
            //               ),
            //               child: Icon(
            //                 Icons.alarm_off,
            //                 color: Colors.green[700],
            //                 size: 20,
            //               ),
            //             ),
            //             const SizedBox(width: 16),
            //             Text(
            //               'Dismiss Alarm',
            //               style: theme.textTheme.titleMedium?.copyWith(
            //                 fontWeight: FontWeight.w600,
            //                 color: Colors.green[700],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withOpacity(0.2)
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled
                  ? color.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? color.withOpacity(0.3)
                      : colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isEnabled
                      ? color
                      : colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundTriggers(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sound Triggers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 16),
            ...soundTriggers.entries.map((entry) {
              final isActive = entry.value;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        soundTriggers[entry.key] = !soundTriggers[entry.key]!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? kSecondaryColor.withOpacity(0.3)
                            : colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? kPrimaryColor.withOpacity(0.3)
                              : colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive ? kSecondaryColor : colorScheme.surfaceVariant.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(entry.key),
                              color: isActive ? kPrimaryColor : colorScheme.onSurface.withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getSubtitle(entry.key),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                soundTriggers[entry.key] = value;
                              });
                            },
                            activeColor: kPrimaryColor,
                            activeTrackColor: kSecondaryColor,
                            inactiveThumbColor: colorScheme.outline,
                            inactiveTrackColor: colorScheme.surfaceVariant,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoudNoiseTrigger(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLoudNoiseEnabled ? kSecondaryColor : colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: isLoudNoiseEnabled ? kPrimaryColor : colorScheme.onSurface.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loud Noise Detection',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontFamily: kFont,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Triggers when sound exceeds threshold',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isLoudNoiseEnabled,
                  onChanged: (value) {
                    setState(() {
                      isLoudNoiseEnabled = value;
                    });
                  },
                  activeColor: kPrimaryColor,
                  activeTrackColor: kSecondaryColor,
                  inactiveThumbColor: colorScheme.outline,
                  inactiveTrackColor: colorScheme.surfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Threshold: ${loudNoiseThreshold.toInt()} dB',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: kPrimaryColor,
                inactiveTrackColor: colorScheme.surfaceVariant,
                thumbColor: kPrimaryColor,
                overlayColor: kPrimaryColor.withOpacity(0.2),
                valueIndicatorColor: kPrimaryColor,
                valueIndicatorTextStyle: TextStyle(
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Slider(
                min: 40,
                max: 120,
                divisions: 80,
                value: loudNoiseThreshold,
                label: "${loudNoiseThreshold.toInt()} dB",
                onChanged: (val) {
                  setState(() {
                    loudNoiseThreshold = val;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDetectedEvents(List<String> newEvents) {
    // Update cached events
    setState(() {
      _cachedDetectedEvents = List<String>.from(newEvents);
    });
  }

  String _getSubtitle(String trigger) {
    switch (trigger) {
      case "Smoke Alarm":
        return "Recognizes standard smoke alarm sounds";
      case "Fire Alarm":
        return "Detects fire alarm patterns";
      case "Doorbell":
        return "Identifies doorbell sounds";
      case "Siren":
        return "Detects emergency vehicle sirens";
      case "Buzzer":
        return "Recognizes buzzer sounds";
      case "Beep":
        return "Identifies electronic beeping";
      case "Baby cry":
        return "Detects baby cry sounds";
      default:
        return "";
    }
  }

  IconData _getIcon(String trigger) {
    switch (trigger) {
      case "Smoke Alarm":
        return Icons.smoke_free;
      case "Fire Alarm":
        return Icons.local_fire_department;
      case "Doorbell":
        return Icons.doorbell;
      case "Siren":
        return Icons.emergency;
      case "Buzzer":
        return Icons.campaign;
      case "Beep":
        return Icons.sensors;
      case "Baby cry":
        return Icons.child_care;
      default:
        return Icons.music_note;
    }
  }
}