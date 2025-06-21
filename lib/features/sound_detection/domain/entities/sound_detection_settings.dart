class SoundDetectionSettings {
  final double dbThreshold;
  final List<String> triggeringSounds;
  final bool isLoudNoiseEnabled;

  SoundDetectionSettings({required this.dbThreshold, required this.triggeringSounds, required this.isLoudNoiseEnabled});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'dbThreshold': dbThreshold,
      'triggeringSounds': triggeringSounds,
      'isLoudNoiseEnabled': isLoudNoiseEnabled,
    };
  }

  // Create from JSON
  factory SoundDetectionSettings.fromJson(Map<String, dynamic> json) {
  return SoundDetectionSettings(
  dbThreshold: (json['dbThreshold'] as num).toDouble(),
  triggeringSounds: List<String>.from(json['triggeringSounds'] ?? []),
    isLoudNoiseEnabled: (json['isLoudNoiseEnabled'] ?? true),
  );
  }

  // Create a copy with modified values
  SoundDetectionSettings copyWith({
  double? dbThreshold,
  List<String>? triggeringSounds,
    bool? isLoudNoiseEnabled,
  }) {
  return SoundDetectionSettings(
  dbThreshold: dbThreshold ?? this.dbThreshold,
  triggeringSounds: triggeringSounds ?? this.triggeringSounds,
    isLoudNoiseEnabled: isLoudNoiseEnabled ?? this.isLoudNoiseEnabled,
  );
  }

  // Equality and hashCode for comparing instances
  @override
  bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is SoundDetectionSettings &&
  other.dbThreshold == dbThreshold &&
  _listEquals(other.triggeringSounds, triggeringSounds) &&
    other.isLoudNoiseEnabled == isLoudNoiseEnabled;
  }

  @override
  int get hashCode => Object.hash(dbThreshold, Object.hashAll(triggeringSounds));

  bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
  if (a[i] != b[i]) return false;
  }
  return true;
  }

  @override
  String toString() {
  return 'SoundDetectionSettings(dbThreshold: $dbThreshold, triggeringSounds: $triggeringSounds), isLoudNoiseEnabled: $isLoudNoiseEnabled)';
  }
}