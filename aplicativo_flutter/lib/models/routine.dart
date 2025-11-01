class Routine {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Routine({required this.id, required this.name, required this.exercises});

  int get totalDuration => exercises.fold(0, (p, e) => p + e.seconds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    final ex = (json['exercises'] as List<dynamic>?)
            ?.map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return Routine(id: json['id'] ?? '', name: json['name'] ?? '', exercises: ex);
  }
}

class Exercise {
  final String name;
  final int seconds;

  Exercise({required this.name, required this.seconds});

  Map<String, dynamic> toJson() => {'name': name, 'seconds': seconds};

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      Exercise(name: json['name'] ?? '', seconds: json['seconds'] ?? 0);
}
