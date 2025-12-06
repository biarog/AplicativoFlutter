import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the schedule of routines for each day of the week
/// Days are indexed 0-6: Monday-Sunday
class WeeklySchedule {
  final Map<int, String?> routineIdsByDay; // day -> routineId

  WeeklySchedule({
    required this.routineIdsByDay,
  });

  String? getRoutineIdForDay(int dayOfWeek) {
    // Convert Flutter's weekday (1=Monday, 7=Sunday) to our format (0-6)
    final normalizedDay = dayOfWeek == 7 ? 6 : dayOfWeek - 1;
    return routineIdsByDay[normalizedDay];
  }

  WeeklySchedule copyWith({
    Map<int, String?>? routineIdsByDay,
  }) {
    return WeeklySchedule(
      routineIdsByDay: routineIdsByDay ?? this.routineIdsByDay,
    );
  }

  Map<String, dynamic> toJson() => {
    'routineIdsByDay': routineIdsByDay,
  };

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    final data = json['routineIdsByDay'] as Map<String, dynamic>?;
    final routineIdsByDay = <int, String?>{};
    
    if (data != null) {
      data.forEach((key, value) {
        routineIdsByDay[int.parse(key)] = value as String?;
      });
    }

    return WeeklySchedule(routineIdsByDay: routineIdsByDay);
  }

  // Create an empty schedule
  factory WeeklySchedule.empty() {
    return WeeklySchedule(
      routineIdsByDay: {0: null, 1: null, 2: null, 3: null, 4: null, 5: null, 6: null},
    );
  }
}

/// Notifier for managing weekly schedule
class ScheduleNotifier extends Notifier<WeeklySchedule> {
  @override
  WeeklySchedule build() {
    return WeeklySchedule.empty();
  }

  void setRoutineForDay(int day, String? routineId) {
    final updated = <int, String?>{...state.routineIdsByDay};
    updated[day] = routineId;
    state = state.copyWith(routineIdsByDay: updated);
  }

  void loadSchedule(WeeklySchedule schedule) {
    state = schedule;
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, WeeklySchedule>(
  ScheduleNotifier.new,
);
