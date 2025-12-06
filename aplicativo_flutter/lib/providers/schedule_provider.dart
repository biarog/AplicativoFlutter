import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Represents the schedule of routines for each day of the week
/// Days are indexed 0-6: Monday-Sunday
class WeeklySchedule {
  final Map<int, List<String>> routineIdsByDay; // day -> list of routineIds

  WeeklySchedule({
    required this.routineIdsByDay,
  });

  List<String> getRoutineIdsForDay(int dayOfWeek) {
    // Convert Flutter's weekday (1=Monday, 7=Sunday) to our format (0-6)
    final normalizedDay = dayOfWeek == 7 ? 6 : dayOfWeek - 1;
    return routineIdsByDay[normalizedDay] ?? [];
  }

  WeeklySchedule copyWith({
    Map<int, List<String>>? routineIdsByDay,
  }) {
    return WeeklySchedule(
      routineIdsByDay: routineIdsByDay ?? this.routineIdsByDay,
    );
  }

  Map<String, dynamic> toJson() => {
    'routineIdsByDay': routineIdsByDay.map((key, value) => 
      MapEntry(key.toString(), value)),
  };

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    final data = json['routineIdsByDay'] as Map<String, dynamic>?;
    final routineIdsByDay = <int, List<String>>{};
    
    if (data != null) {
      data.forEach((key, value) {
        final day = int.parse(key);
        final ids = (value as List<dynamic>).cast<String>();
        routineIdsByDay[day] = ids;
      });
    }

    return WeeklySchedule(routineIdsByDay: routineIdsByDay);
  }

  // Create an empty schedule
  factory WeeklySchedule.empty() {
    return WeeklySchedule(
      routineIdsByDay: {
        0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []
      },
    );
  }
}

/// Notifier for managing weekly schedule with persistence
class ScheduleNotifier extends AsyncNotifier<WeeklySchedule> {
  @override
  Future<WeeklySchedule> build() async {
    return _loadScheduleFromStorage();
  }

  Future<WeeklySchedule> _loadScheduleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weekly_schedule');
      
      if (jsonString != null) {
        debugPrint('📅 Carregando agenda do storage');
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return WeeklySchedule.fromJson(json);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar agenda: $e');
    }
    
    return WeeklySchedule.empty();
  }

  Future<void> _saveScheduleToStorage(WeeklySchedule schedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = schedule.toJson();
      final jsonString = jsonEncode(json);
      await prefs.setString('weekly_schedule', jsonString);
      debugPrint('💾 Agenda salva com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao salvar agenda: $e');
    }
  }

  void addRoutineToDay(int day, String routineId) async {
    final current = state.value ?? WeeklySchedule.empty();
    final updated = <int, List<String>>{...current.routineIdsByDay};
    
    if (!updated[day]!.contains(routineId)) {
      updated[day] = [...updated[day]!, routineId];
      final newSchedule = current.copyWith(routineIdsByDay: updated);
      state = AsyncValue.data(newSchedule);
      await _saveScheduleToStorage(newSchedule);
    }
  }

  void removeRoutineFromDay(int day, String routineId) async {
    final current = state.value ?? WeeklySchedule.empty();
    final updated = <int, List<String>>{...current.routineIdsByDay};
    
    updated[day] = updated[day]!.where((id) => id != routineId).toList();
    final newSchedule = current.copyWith(routineIdsByDay: updated);
    state = AsyncValue.data(newSchedule);
    await _saveScheduleToStorage(newSchedule);
  }

  void clearDaySchedule(int day) async {
    final current = state.value ?? WeeklySchedule.empty();
    final updated = <int, List<String>>{...current.routineIdsByDay};
    updated[day] = [];
    
    final newSchedule = current.copyWith(routineIdsByDay: updated);
    state = AsyncValue.data(newSchedule);
    await _saveScheduleToStorage(newSchedule);
  }
}

final scheduleProvider = AsyncNotifierProvider<ScheduleNotifier, WeeklySchedule>(
  ScheduleNotifier.new,
);
