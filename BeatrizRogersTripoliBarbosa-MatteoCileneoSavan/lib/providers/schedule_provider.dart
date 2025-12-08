import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider.dart';

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
    // Listen to auth state changes to sync with Firebase
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // User logged in - load from Firebase
          _syncFromFirebase(user.uid);
        }
      });
    });
    
    return _loadScheduleFromStorage();
  }

  Future<WeeklySchedule> _loadScheduleFromStorage() async {
    try {
      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Try to load from Firebase first
        final firebaseSchedule = await ref.read(authRepositoryProvider).fetchScheduleForUser(user.uid);
        if (firebaseSchedule != null) {
          debugPrint('📅 Carregando agenda do Firebase');
          final schedule = WeeklySchedule.fromJson(firebaseSchedule);
          // Save to local storage as cache
          await _saveScheduleToLocalStorage(schedule);
          return schedule;
        }
      }
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weekly_schedule');
      
      if (jsonString != null) {
        debugPrint('📅 Carregando agenda do storage local');
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return WeeklySchedule.fromJson(json);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar agenda: $e');
    }
    
    return WeeklySchedule.empty();
  }

  Future<void> _saveScheduleToLocalStorage(WeeklySchedule schedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = schedule.toJson();
      final jsonString = jsonEncode(json);
      await prefs.setString('weekly_schedule', jsonString);
    } catch (e) {
      debugPrint('❌ Erro ao salvar agenda localmente: $e');
    }
  }

  Future<void> _saveScheduleToStorage(WeeklySchedule schedule) async {
    try {
      // Save to local storage
      await _saveScheduleToLocalStorage(schedule);
      debugPrint('💾 Agenda salva localmente com sucesso');
      
      // If user is logged in, also save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ref.read(authRepositoryProvider).saveScheduleForUser(user.uid, schedule.toJson());
        debugPrint('☁️ Agenda sincronizada com Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar agenda: $e');
    }
  }

  Future<void> _syncFromFirebase(String uid) async {
    try {
      final firebaseSchedule = await ref.read(authRepositoryProvider).fetchScheduleForUser(uid);
      if (firebaseSchedule != null) {
        final schedule = WeeklySchedule.fromJson(firebaseSchedule);
        state = AsyncValue.data(schedule);
        await _saveScheduleToLocalStorage(schedule);
        debugPrint('🔄 Agenda sincronizada do Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao sincronizar agenda do Firebase: $e');
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
