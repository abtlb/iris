import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../domain/entities/alarm_entity.dart';
import '../../../domain/repositories/alarm_repository.dart';

part 'alarm_list_state.dart';

/// Manages CRUD for scheduled alarms
class AlarmListCubit extends Cubit<AlarmListState> {
  final AlarmRepository repository;

  AlarmListCubit({required this.repository}) : super(AlarmListInitial());

  Future<void> loadAlarms() async {
    try {
      print("loading");
      emit(AlarmListLoading());
      final alarms = await repository.getAllAlarms();
      emit(AlarmListLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmListError(message: e.toString()));
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    await repository.scheduleAlarm(alarm);
    await loadAlarms();
  }

  Future<void> removeAlarm(int id) async {
    await repository.cancelAlarm(id);
    await loadAlarms();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await repository.updateAlarm(alarm);
    await loadAlarms();
  }
  
  Future<void> toggleAlarm(Alarm alarm) async {
    var newAlarm = alarm.copyWith(isEnabled: !alarm.isEnabled);
    updateAlarm(newAlarm);
  }

  Future<void> ignoreBatteryOptimizations() async {
    final info = await PackageInfo.fromPlatform();
    final pkgName = info.packageName;
    var intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:$pkgName',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      print("Launching battery optimization settings...");
      await intent.launch();
      print("Battery optimization settings opened successfully.");
    } catch (e) {
      print("Error: $e");
    }
  }
}