/// lib/features/alarm/data/datasources/local_alarm_ds.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart'; // a JSON‐serializable DTO

class LocalAlarmDataSource {
  static const _key = 'stored_alarms';

  Future<List<AlarmModel>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString) as List;
    var alarmModels = decoded
        .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
        .toList();
    //todo delete this
    alarmModels.forEach((e) => print("Alarm pattern after loading: ${e.pattern}"));
    return alarmModels;
  }


  /// Saves the current list of alarms to local storage.
  Future<void> _saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(alarms.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Adds a new alarm to local storage.
  Future<void> addAlarm(AlarmModel alarm) async {
    final alarms = await loadAlarms();
    alarms.add(alarm);
    await _saveAlarms(alarms);
  }

  /// Deletes an alarm by ID.
  Future<void> deleteAlarm(int alarmId) async {
    final alarms = await loadAlarms();
    alarms.removeWhere((a) => a.id == alarmId);
    await _saveAlarms(alarms);
  }

  /// Clears all alarms.
  Future<void> clearAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Finds a specific alarm by ID.
  Future<AlarmModel?> getAlarmById(int alarmId) async {
    final alarms = await loadAlarms();
    return alarms.firstWhere((a) => a.id == alarmId);
  }
}
