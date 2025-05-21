enum WeekDay {
  saturday, sunday, monday, tuesday, wednesday, thursday, friday
}

extension WeekDayX on WeekDay {
  static const List<WeekDay> daysOfWeek = [
    WeekDay.monday,
    WeekDay.tuesday,
    WeekDay.wednesday,
    WeekDay.thursday,
    WeekDay.friday,
    WeekDay.saturday,
    WeekDay.sunday,
  ];

  static WeekDay fromShortName(String shortName) {
    switch (shortName) {
      case 'Mon': return WeekDay.monday;
      case 'Tue': return WeekDay.tuesday;
      case 'Wed': return WeekDay.wednesday;
      case 'Thu': return WeekDay.thursday;
      case 'Fri': return WeekDay.friday;
      case 'Sat': return WeekDay.saturday;
      case 'Sun': return WeekDay.sunday;
      default: throw ArgumentError('Invalid shortName for WeekDay: $shortName');
    }
  }

  /// Short label for UI chips
  String get shortName {
    switch (this) {
      case WeekDay.monday:    return 'Mon';
      case WeekDay.tuesday:   return 'Tue';
      case WeekDay.wednesday: return 'Wed';
      case WeekDay.thursday:  return 'Thu';
      case WeekDay.friday:    return 'Fri';
      case WeekDay.saturday:  return 'Sat';
      case WeekDay.sunday:    return 'Sun';
    }
  }

  /// For JSON (e.g. “monday”)
  String get name => toString().split('.').last;

  static WeekDay fromName(String name) =>
      WeekDay.values.firstWhere((d) => d.name == name);
}
