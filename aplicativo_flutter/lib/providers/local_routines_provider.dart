import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';

/// Notifier para gerenciar rotinas locais (sem necessidade de login)
class LocalRoutinesNotifier extends Notifier<List<Routine>> {
  @override
  List<Routine> build() {
    return <Routine>[];
  }

  void addRoutine(Routine routine) {
    state = [...state, routine];
  }

  void removeRoutine(String routineId) {
    state = state.where((r) => r.id != routineId).toList();
  }

  void updateRoutine(Routine routine) {
    state = state.map((r) => r.id == routine.id ? routine : r).toList();
  }
}

/// Provider para armazenar rotinas locais
final localRoutinesProvider = NotifierProvider<LocalRoutinesNotifier, List<Routine>>(
  LocalRoutinesNotifier.new,
);
