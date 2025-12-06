import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';

/// Notifier para gerenciar rotinas locais (persistidas no dispositivo)
class LocalRoutinesNotifier extends AsyncNotifier<List<Routine>> {
  static const String _storageKey = 'local_routines';

  @override
  Future<List<Routine>> build() async {
    return _loadRoutinesFromStorage();
  }

  /// Carrega rotinas do armazenamento local
  Future<List<Routine>> _loadRoutinesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? <String>[];
      debugPrint('📂 Carregando ${jsonList.length} rotina(s) do armazenamento local');
      
      final routines = jsonList
          .map((jsonStr) {
            try {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              return Routine.fromJson(map);
            } catch (e) {
              debugPrint('❌ Erro ao parsear rotina local: $e');
              return null;
            }
          })
          .whereType<Routine>()
          .toList();
      
      debugPrint('✅ ${routines.length} rotina(s) carregada(s) com sucesso');
      for (var routine in routines) {
        debugPrint('   - ${routine.name} (${routine.exercises.length} exercícios)');
      }
      
      return routines;
    } catch (e) {
      debugPrint('❌ Erro ao carregar rotinas locais: $e');
      return <Routine>[];
    }
  }

  /// Salva rotinas no armazenamento local
  Future<void> _saveRoutinesToStorage(List<Routine> routines) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = routines
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, jsonList);
      debugPrint('💾 ${routines.length} rotina(s) persistida(s) em SharedPreferences');
    } catch (e) {
      debugPrint('❌ Erro ao salvar rotinas locais: $e');
    }
  }

  Future<void> addRoutine(Routine routine) async {
    final currentState = await future;
    final updatedList = [...currentState, routine];
    state = AsyncValue.data(updatedList);
    await _saveRoutinesToStorage(updatedList);
    debugPrint('✅ Rotina "${routine.name}" salva localmente. Total: ${updatedList.length}');
  }

  Future<void> removeRoutine(String routineId) async {
    final currentState = await future;
    final updatedList = currentState.where((r) => r.id != routineId).toList();
    state = AsyncValue.data(updatedList);
    await _saveRoutinesToStorage(updatedList);
    debugPrint('🗑️ Rotina removida. Total restante: ${updatedList.length}');
  }

  Future<void> updateRoutine(Routine routine) async {
    final currentState = await future;
    final updatedList = currentState.map((r) => r.id == routine.id ? routine : r).toList();
    state = AsyncValue.data(updatedList);
    await _saveRoutinesToStorage(updatedList);
  }
}

/// Provider para armazenar rotinas locais (persistidas no dispositivo)
final localRoutinesProvider = AsyncNotifierProvider<LocalRoutinesNotifier, List<Routine>>(
  LocalRoutinesNotifier.new,
);
