import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torch_light/torch_light.dart';
import 'package:untitled3/core/constants/constants.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/entities/week_day.dart';
import '../bloc/alarm_form/alarm_form_cubit.dart';
import '../bloc/alarm_form/alarm_form_state.dart';
import '../widgets/pattern_row.dart';

class SetAlarmPage extends StatefulWidget {
  final Alarm? alarm;

  const SetAlarmPage({super.key, this.alarm});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage>
    with TickerProviderStateMixin {
  late final TextEditingController labelController;
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.alarm?.label ?? '');

    // Animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    labelController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => AlarmFormCubit(initialAlarm: widget.alarm),
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
              widget.alarm != null ? 'Edit Alarm' : 'New Alarm',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: kFont,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: colorScheme.onSurface,
                semanticLabel: 'Cancel',
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<AlarmFormCubit, AlarmFormState>(
            builder: (context, state) {
              final alarm = state.alarm;

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Time Picker Section
                              _buildTimePickerSection(context, alarm, colorScheme, theme),
                              const SizedBox(height: 24),

                              // Label Section
                              _buildLabelSection(context, state, colorScheme, theme),
                              const SizedBox(height: 24),

                              // Repeat Days Section
                              _buildRepeatDaysSection(context, alarm, colorScheme, theme),
                              const SizedBox(height: 24),

                              // Alarm Pattern Section
                              _buildAlarmPatternSection(context, state, colorScheme, theme),
                              const SizedBox(height: 24),

                              // Settings Section
                              _buildSettingsSection(context, state, colorScheme, theme),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Bottom Action Bar
                        _buildBottomActionBar(context, state, colorScheme, theme),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerSection(
      BuildContext context,
      Alarm alarm,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Icon(
            Icons.access_time_outlined,
            size: 32,
            color: kTextPrimary,
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showTimePicker(context, alarm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Text(
                TimeOfDay.fromDateTime(alarm.time).format(context),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: kTextPrimary,
                  fontFamily: GoogleFonts.rubik().fontFamily,
                  fontSize: 55
                ),
                semanticsLabel: 'Alarm time ${TimeOfDay.fromDateTime(alarm.time).format(context)}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to change time',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontFamily: kFont,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelSection(
      BuildContext context,
      AlarmFormState state,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
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
              Icon(
                Icons.label_outline,
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alarm Label',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: kFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: labelController,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: 'Enter alarm name (optional)',
              filled: true,
              fillColor: kSecondaryColor.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: kPrimaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '',
              suffixIcon: labelController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  labelController.clear();
                  context.read<AlarmFormCubit>().updateLabel('');
                },
              )
                  : null,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: kFont,
              color: kTextPrimary,
            ),
            onChanged: (value) {
              context.read<AlarmFormCubit>().updateLabel(value);
              setState(() {}); // Rebuild to show/hide clear button
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatDaysSection(
      BuildContext context,
      Alarm alarm,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
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
              Icon(
                Icons.repeat,
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Repeat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: kFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WeekDay.values.map((day) {
              final selected = alarm.repeatDays.contains(day);
              return FilterChip(
                label: Text(
                  day.shortName,
                  style: TextStyle(
                    color: selected
                        ? kSecondaryColor
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontFamily: kFont,
                  ),
                ),
                selected: selected,
                onSelected: (_) => _toggleRepeatDay(context, alarm, day),
                backgroundColor: kSecondaryColor.withOpacity(0.8),
                selectedColor: kPrimaryColor,
                checkmarkColor: kSecondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected
                        ? kPrimaryColor
                        : colorScheme.outline.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                elevation: selected ? 2 : 0,
                pressElevation: 4,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.comfortable,
              );
            }).toList(),
          ),
          if (alarm.repeatDays.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Select days to repeat this alarm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontFamily: kFont,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlarmPatternSection(
      BuildContext context,
      AlarmFormState state,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
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
              Icon(
                Icons.graphic_eq,
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alarm Pattern',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: kFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NumberSlider(
            initialValue: state.alarm.pattern,
            onValueChanged: (value) {
              context.read<AlarmFormCubit>().updatePattern(value);
              // Haptic feedback
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context,
      AlarmFormState state,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
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
              Icon(
                Icons.settings_outlined,
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: kFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: Text(
              'Enable Alarm',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: kFont,
              ),
            ),
            subtitle: Text(
              state.alarm.isEnabled ? 'Alarm is active' : 'Alarm is inactive',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontFamily: kFont,
              ),
            ),
            value: state.alarm.isEnabled,
            onChanged: (value) {
              context.read<AlarmFormCubit>().toggleEnabled();
              HapticFeedback.lightImpact();
            },
            activeColor: kPrimaryColor,
            activeTrackColor: kSecondaryColor,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.comfortable,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
      BuildContext context,
      AlarmFormState state,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                ),
                backgroundColor: kSecondaryColor.withOpacity(0.8),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: kFont,
                  color: kTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Save button
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: state.isValid ? () => _saveAlarm(context, state.alarm) : null,
              style: FilledButton.styleFrom(
                backgroundColor: state.isValid ? kPrimaryColor : colorScheme.surfaceVariant,
                disabledBackgroundColor: colorScheme.surfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    color: state.isValid
                        ? kSecondaryColor
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.alarm != null ? 'Update Alarm' : 'Save Alarm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: kFont,
                      color: state.isValid
                          ? kSecondaryColor
                          : colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context, Alarm alarm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(alarm.time),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: kSecondaryColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dialHandColor: kPrimaryColor,
              dialBackgroundColor: kSecondaryColor.withOpacity(0.8),
              hourMinuteColor: kSecondaryColor.withOpacity(0.8),
              hourMinuteTextColor: kTextPrimary,
              dayPeriodColor: kPrimaryColor,
              dayPeriodTextColor: kSecondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final newTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      context.read<AlarmFormCubit>().updateTime(newTime);
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleRepeatDay(BuildContext context, Alarm alarm, WeekDay day) {
    final newDays = List<WeekDay>.from(alarm.repeatDays);
    final selected = newDays.contains(day);

    if (selected) {
      newDays.remove(day);
    } else {
      newDays.add(day);
    }

    context.read<AlarmFormCubit>().updateRepeat(newDays);
    HapticFeedback.selectionClick();
  }

  void _saveAlarm(BuildContext context, Alarm alarm) {
    Navigator.of(context).pop(alarm);
    HapticFeedback.lightImpact();
  }
}