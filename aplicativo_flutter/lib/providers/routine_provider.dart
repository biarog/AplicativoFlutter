import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import 'auth_provider.dart';
import 'local_routines_provider.dart';

/// Provider que retorna todas as rotinas (locais + do Firebase)
final userRoutinesProvider = FutureProvider<List<Routine>>((ref) async {
  // Aguardar rotinas locais
  final localRoutinesAsync = ref.watch(localRoutinesProvider);
  final localRoutines = localRoutinesAsync.when(
    data: (routines) => routines,
    loading: () => <Routine>[],
    error: (_, _) => <Routine>[],
  );
  
  debugPrint('Rotinas locais: ${localRoutines.length}');
  for (var routine in localRoutines) {
    debugPrint('  - ${routine.name} (id: ${routine.id})');
  }

  // Tentar carregar rotinas do Firebase se houver usuário logado
  final authRepository = ref.watch(authRepositoryProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) {
        debugPrint('Usuário não logado, usando apenas rotinas locais');
        return localRoutines;
      }
      
      try {
        final firebaseRoutines = await authRepository.fetchRoutinesForUserAsModels(user.uid);
        debugPrint('Rotinas do Firebase: ${firebaseRoutines.length}');
        for (var routine in firebaseRoutines) {
          debugPrint('  - ${routine.name} (id: ${routine.id})');
        }
        
        // Combinar rotinas locais com as do Firebase
        // Evitar duplicatas por ID
        final allRoutines = <String, Routine>{};
        
        for (var routine in localRoutines) {
          allRoutines[routine.id] = routine;
        }
        
        for (var routine in firebaseRoutines) {
          allRoutines[routine.id] = routine;
        }
        
        final combined = allRoutines.values.toList();
        debugPrint('Total de rotinas (local + Firebase): ${combined.length}');
        return combined;
      } catch (e) {
        debugPrint('Erro ao carregar rotinas do Firebase: $e');
        debugPrint('Usando apenas rotinas locais como fallback');
        return localRoutines;
      }
    },
    loading: () async {
      debugPrint('Carregando estado de autenticação...');
      return localRoutines;
    },
    error: (err, stack) async {
      debugPrint('Erro no authState: $err');
      return localRoutines;
    },
  );
});
