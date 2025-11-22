class Routine {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Routine({required this.id, required this.name, required this.exercises});

  // Total duration counts only timed exercises
  int get totalDuration =>
      exercises.whereType<TimedExercise>().fold<int>(0, (p, e) => p + e.seconds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    // Handle legacy 'legacy_raw' entries by preserving the raw string in
    // the routine name so the app can still display something useful.
    if (json.containsKey('legacy_raw') && json['legacy_raw'] is String) {
      final raw = json['legacy_raw'] as String;
      final id = json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final name = json['name'] ?? raw;
      return Routine(id: id, name: name, exercises: <Exercise>[]);
    }

    final ex = (json['exercises'] as List<dynamic>?)
            ?.map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return Routine(id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(), name: json['name'] ?? '', exercises: ex);
  }
}

/// Base exercise type. Concrete types: [TimedExercise], [CountingExercise].
abstract class Exercise {
  final String name;
  final String? youtubeUrl;
  final int? youtubeStartSeconds;

  Exercise({required this.name, this.youtubeUrl, this.youtubeStartSeconds});

  Map<String, dynamic> toJson();

  /// Polymorphic deserialization. Uses `type` field when present. Falls back
  /// to checking for `seconds` to maintain some backwards compatibility.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String?)?.toLowerCase();
    if (type == 'timed' || json.containsKey('seconds')) {
      return TimedExercise.fromJson(json);
    }

    // Default to counting if not timed
    return CountingExercise.fromJson(json);
  }
}

class TimedExercise extends Exercise {
  final int seconds;

  TimedExercise({required super.name, required this.seconds, super.youtubeUrl, super.youtubeStartSeconds});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'timed',
    'name': name,
    'seconds': seconds,
    'youtubeUrl': youtubeUrl,
    'youtubeStartSeconds': youtubeStartSeconds,
    };

  factory TimedExercise.fromJson(Map<String, dynamic> json) => TimedExercise(
    name: json['name'] ?? '',
    seconds: (json['seconds'] is int)
      ? json['seconds'] as int
      : (int.tryParse('${json['seconds']}') ?? 0),
    youtubeUrl: json['youtubeUrl'] as String?,
        youtubeStartSeconds: json['youtubeStartSeconds'] is int
          ? json['youtubeStartSeconds'] as int
          : (json['youtubeStartSeconds'] == null
            ? null
            : int.tryParse('${json['youtubeStartSeconds']}')),
    );
}

class CountingExercise extends Exercise {
  final int sets;
  final int reps;
  final double? weight; // null when no weight is involved

  CountingExercise({
    required super.name,
    required this.sets,
    required this.reps,
    this.weight,
    super.youtubeUrl,
    super.youtubeStartSeconds,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'counting',
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'youtubeUrl': youtubeUrl,
        'youtubeStartSeconds': youtubeStartSeconds,
      };

  factory CountingExercise.fromJson(Map<String, dynamic> json) => CountingExercise(
        name: json['name'] ?? '',
        sets: (json['sets'] is int)
            ? json['sets'] as int
            : (int.tryParse('${json['sets']}') ?? 0),
        reps: (json['reps'] is int)
            ? json['reps'] as int
            : (int.tryParse('${json['reps']}') ?? 0),
        weight: json['weight'] == null
            ? null
            : (json['weight'] is num ? (json['weight'] as num).toDouble() : double.tryParse('${json['weight']}')),
      youtubeUrl: json['youtubeUrl'] as String?,
      youtubeStartSeconds: json['youtubeStartSeconds'] is int
        ? json['youtubeStartSeconds'] as int
        : (json['youtubeStartSeconds'] == null
          ? null
          : int.tryParse('${json['youtubeStartSeconds']}')),
      );
}
