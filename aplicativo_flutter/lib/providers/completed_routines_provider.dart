import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier para gerenciar rotinas completadas
class CompletedRoutinesNotifier extends AsyncNotifier<Map<String, Set<String>>> {
  static const String _storageKeyPrefix = 'completed_dates_';

  @override
  Future<Map<String, Set<String>>> build() async {
    return _loadCompletedRoutinesFromStorage();
  }

  /// Carrega rotinas completadas do armazenamento local
  Future<Map<String, Set<String>>> _loadCompletedRoutinesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = <String, Set<String>>{};

      // Procura por todas as chaves que começam com o prefixo
      for (final key in prefs.getKeys()) {
        if (key.startsWith(_storageKeyPrefix)) {
          final routineId = key.replaceFirst(_storageKeyPrefix, '');
          final dates = prefs.getStringList(key) ?? <String>[];
          result[routineId] = Set<String>.from(dates);
        }
      }

      return result;
    } catch (e) {
      debugPrint('Erro ao carregar rotinas completadas: $e');
      return <String, Set<String>>{};
    }
  }

  /// Marca uma rotina como completada em um dia específico
  Future<void> markRoutineAsCompleted(String routineId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = DateTime(date.year, date.month, date.day).toIso8601String();

      // Obter datas existentes para esta rotina
      final key = '$_storageKeyPrefix$routineId';
      final existingDates = prefs.getStringList(key) ?? <String>[];

      // Adicionar nova data se não existir
      if (!existingDates.contains(dateString)) {
        existingDates.add(dateString);
        await prefs.setStringList(key, existingDates);
      }

      // Atualizar o estado
      final currentState = await future;
      final updatedState = Map<String, Set<String>>.from(currentState);
      updatedState[routineId] = Set<String>.from(existingDates);
      state = AsyncValue.data(updatedState);

      debugPrint('Rotina $routineId marcada como completada em $dateString');
    } catch (e) {
      debugPrint('Erro ao marcar rotina como completada: $e');
    }
  }

  /// Verifica se uma rotina foi completada em um dia específico
  Future<bool> isRoutineCompletedOnDate(String routineId, DateTime date) async {
    final currentState = await future;
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String();
    return currentState[routineId]?.contains(dateString) ?? false;
  }

  /// Obtém todas as datas em que uma rotina foi completada
  Future<Set<String>> getCompletedDates(String routineId) async {
    final currentState = await future;
    return currentState[routineId] ?? <String>{};
  }

  /// Verifica se alguma rotina foi completada em uma data específica
  Future<bool> hasAnyCompletedRoutineOnDate(List<String> routineIds, DateTime date) async {
    final currentState = await future;
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String();
    return routineIds.any((id) => currentState[id]?.contains(dateString) ?? false);
  }
}

/// Provider para rastrear rotinas completadas
final completedRoutinesProvider =
    AsyncNotifierProvider<CompletedRoutinesNotifier, Map<String, Set<String>>>(
  CompletedRoutinesNotifier.new,
);
