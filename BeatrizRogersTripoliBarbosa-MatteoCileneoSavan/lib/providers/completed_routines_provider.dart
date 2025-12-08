import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider.dart';

/// Notifier para gerenciar rotinas completadas
class CompletedRoutinesNotifier extends AsyncNotifier<Map<String, Set<String>>> {
  static const String _storageKeyPrefix = 'completed_dates_';

  @override
  Future<Map<String, Set<String>>> build() async {
    // Listen to auth state changes to sync with Firebase
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // User logged in - load from Firebase
          _syncFromFirebase(user.uid);
        }
      });
    });
    
    return _loadCompletedRoutinesFromStorage();
  }

  /// Carrega rotinas completadas do armazenamento local ou Firebase
  Future<Map<String, Set<String>>> _loadCompletedRoutinesFromStorage() async {
    try {
      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Try to load from Firebase first
        final firebaseData = await ref.read(authRepositoryProvider).fetchCompletedRoutinesForUser(user.uid);
        if (firebaseData != null) {
          debugPrint('📊 Carregando rotinas completadas do Firebase');
          // Save to local storage as cache
          await _saveToLocalStorage(firebaseData);
          return _cleanOldEntries(firebaseData);
        }
      }
      
      // Fallback to local storage
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

      debugPrint('📊 Carregando rotinas completadas do storage local');
      return _cleanOldEntries(result);
    } catch (e) {
      debugPrint('❌ Erro ao carregar rotinas completadas: $e');
      return <String, Set<String>>{};
    }
  }

  /// Remove entradas com mais de 2 meses
  Map<String, Set<String>> _cleanOldEntries(Map<String, Set<String>> data) {
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
    final cleaned = <String, Set<String>>{};
    
    data.forEach((routineId, dates) {
      final validDates = dates.where((dateStr) {
        try {
          final date = DateTime.parse(dateStr);
          return date.isAfter(twoMonthsAgo);
        } catch (e) {
          return false;
        }
      }).toSet();
      
      if (validDates.isNotEmpty) {
        cleaned[routineId] = validDates;
      }
    });
    
    return cleaned;
  }

  /// Salva no armazenamento local
  Future<void> _saveToLocalStorage(Map<String, Set<String>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear old entries first
      final keysToRemove = prefs.getKeys()
          .where((key) => key.startsWith(_storageKeyPrefix))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      // Save new data
      for (final entry in data.entries) {
        final key = '$_storageKeyPrefix${entry.key}';
        await prefs.setStringList(key, entry.value.toList());
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar localmente: $e');
    }
  }

  /// Salva no storage e sincroniza com Firebase
  Future<void> _saveCompletedRoutines(Map<String, Set<String>> data) async {
    try {
      // Clean old entries before saving
      final cleanedData = _cleanOldEntries(data);
      
      // Save to local storage
      await _saveToLocalStorage(cleanedData);
      debugPrint('💾 Rotinas completadas salvas localmente');
      
      // If user is logged in, also save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firebaseData = cleanedData.map((key, value) => MapEntry(key, value.toList()));
        await ref.read(authRepositoryProvider).saveCompletedRoutinesForUser(user.uid, firebaseData);
        debugPrint('☁️ Rotinas completadas sincronizadas com Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar rotinas completadas: $e');
    }
  }

  /// Sincroniza do Firebase
  Future<void> _syncFromFirebase(String uid) async {
    try {
      final firebaseData = await ref.read(authRepositoryProvider).fetchCompletedRoutinesForUser(uid);
      if (firebaseData != null) {
        final cleanedData = _cleanOldEntries(firebaseData);
        state = AsyncValue.data(cleanedData);
        await _saveToLocalStorage(cleanedData);
        debugPrint('🔄 Rotinas completadas sincronizadas do Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao sincronizar rotinas completadas do Firebase: $e');
    }
  }

  /// Marca uma rotina como completada em um dia específico
  Future<void> markRoutineAsCompleted(String routineId, DateTime date) async {
    try {
      final dateString = DateTime(date.year, date.month, date.day).toIso8601String();

      // Atualizar o estado
      final currentState = await future;
      final updatedState = Map<String, Set<String>>.from(currentState);
      
      if (updatedState[routineId] == null) {
        updatedState[routineId] = <String>{};
      }
      
      updatedState[routineId]!.add(dateString);
      
      // Update state and save
      state = AsyncValue.data(updatedState);
      await _saveCompletedRoutines(updatedState);

      debugPrint('✅ Rotina $routineId marcada como completada em $dateString');
    } catch (e) {
      debugPrint('❌ Erro ao marcar rotina como completada: $e');
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
