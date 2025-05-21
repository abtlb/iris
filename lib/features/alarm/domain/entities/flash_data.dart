/// Represents flash (screen or LED) settings for an alarm.
class FlashData {
  final bool hasFlash;
  final List<int>? flashDurations;

  FlashData({
    required this.hasFlash,
    this.flashDurations,
  });

  /// Converts this [FlashData] into a JSON map.
  Map<String, dynamic> toJson() => {
    'hasFlash': hasFlash,
    'flashDurations': flashDurations,
  };

  /// Constructs a [FlashData] from a JSON map.
  factory FlashData.fromJson(Map<String, dynamic> json) {
    final durations = (json['flashDurations'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList();

    return FlashData(
      hasFlash: json['hasFlash'] as bool,
      flashDurations: durations,
    );
  }
}