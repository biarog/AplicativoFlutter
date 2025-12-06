import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine.dart';
import '../providers/local_routines_provider.dart';

class CreateRoutineScreen extends ConsumerStatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  ConsumerState<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

enum ExerciseType { timed, counting }

class ExerciseTypeNotifier extends Notifier<ExerciseType> {
  @override
  ExerciseType build() => ExerciseType.timed;
  void set(ExerciseType v) => state = v;
}

class UseWeightNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

class ExercisesNotifier extends Notifier<List<Exercise>> {
  @override
  List<Exercise> build() => <Exercise>[];
  void setList(List<Exercise> list) => state = list;
  void addExercise(Exercise e) => state = List.of(state)..add(e);
  void removeAt(int index) {
    final list = List<Exercise>.of(state);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      state = list;
    }
  }
}

final exerciseTypeProvider = NotifierProvider<ExerciseTypeNotifier, ExerciseType>(ExerciseTypeNotifier.new);
final useWeightProvider = NotifierProvider<UseWeightNotifier, bool>(UseWeightNotifier.new);
final exercisesProvider = NotifierProvider<ExercisesNotifier, List<Exercise>>(ExercisesNotifier.new);

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _routineNameController = TextEditingController();

  final _exerciseNameController = TextEditingController();
  final _secondsController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  final _startTimeController = TextEditingController();

  @override
  void dispose() {
    _routineNameController.dispose();
    _exerciseNameController.dispose();
    _secondsController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _youtubeLinkController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final name = _exerciseNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Exercise name is required'),
      ));
      return;
    }
    final formType = ref.read(exerciseTypeProvider);
    final formUseWeight = ref.read(useWeightProvider);

    if (formType == ExerciseType.timed) {
      final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;
      if (seconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a valid duration in seconds'),
        ));
        return;
      }

      String? youtube = _youtubeLinkController.text.trim();
      if (youtube.isEmpty) youtube = null;
      final start = _startTimeController.text.trim().isEmpty
          ? null
          : int.tryParse(_startTimeController.text.trim());

      ref.read(exercisesProvider.notifier).addExercise(
        TimedExercise(name: name, seconds: seconds, youtubeUrl: youtube, youtubeStartSeconds: start),
      );
    } else {
      final sets = int.tryParse(_setsController.text.trim()) ?? 0;
      final reps = int.tryParse(_repsController.text.trim()) ?? 0;
      if (sets <= 0 || reps <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter valid sets and reps'),
        ));
        return;
      }

      double? weight;
      if (formUseWeight) {
        weight = double.tryParse(_weightController.text.trim());
        if (weight == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enter a valid weight'),
          ));
          return;
        }
      }

      String? youtube = _youtubeLinkController.text.trim();
      if (youtube.isEmpty) youtube = null;
      final start = _startTimeController.text.trim().isEmpty
          ? null
          : int.tryParse(_startTimeController.text.trim());

      ref.read(exercisesProvider.notifier).addExercise(
        CountingExercise(
          name: name,
          sets: sets,
          reps: reps,
          weight: weight,
          youtubeUrl: youtube,
          youtubeStartSeconds: start,
        ),
      );
    }

    // Clear exercise inputs
    _exerciseNameController.clear();
    _secondsController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _youtubeLinkController.clear();
    _startTimeController.clear();
    ref.read(exerciseTypeProvider.notifier).set(ExerciseType.timed);
    ref.read(useWeightProvider.notifier).set(false);
  }

  void _removeExercise(int index) {
    ref.read(exercisesProvider.notifier).removeAt(index);
  }

  Future<void> _saveRoutine() async {
    final name = _routineNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Routine name is required'),
      ));
      return;
    }

    final exercises = ref.read(exercisesProvider);

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one exercise to the routine'),
      ));
      return;
    }

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      exercises: List.of(exercises),
    );

    // Sempre salvar localmente e aguardar persistência
    await ref.read(localRoutinesProvider.notifier).addRoutine(routine);

    // Capture UI handles before any async gaps so we don't use
    // BuildContext after awaiting (fixes analyzer lint).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // If a user is logged in, upload the routine as a structured map
    // into the user's `routines` array field.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'routines': FieldValue.arrayUnion([routine.toJson()]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Routine saved to your account')));
        navigator.pop(routine);
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('Failed to save routine: $e')));
        // Still return the routine to the caller so the UI can update locally.
        navigator.pop(routine);
      }
      return;
    }

    // No signed-in user: just return the routine (local/in-memory save).
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Routine saved locally')));
    navigator.pop(routine);
  }

  Widget _buildExerciseForm() {
    final formType = ref.watch(exerciseTypeProvider);
    final formUseWeight = ref.watch(useWeightProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _exerciseNameController,
          decoration: const InputDecoration(labelText: 'Exercise name'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ExerciseType>(
          initialValue: formType,
          decoration: const InputDecoration(labelText: 'Exercise type'),
          items: const [
            DropdownMenuItem(value: ExerciseType.timed, child: Text('Timed')),
            DropdownMenuItem(value: ExerciseType.counting, child: Text('Counting')),
          ],
          onChanged: (ExerciseType? v) {
            if (v != null) ref.read(exerciseTypeProvider.notifier).set(v);
          },
        ),
        const SizedBox(height: 8),
        if (formType == ExerciseType.timed) ...[
          TextField(
            controller: _secondsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (seconds)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _youtubeLinkController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'YouTube link (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _startTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Start time (seconds, optional)'),
          ),
          const SizedBox(height: 8),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sets'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: ref.watch(useWeightProvider),
                onChanged: (v) => ref.read(useWeightProvider.notifier).set(v ?? false),
              ),
              const Text('Use weight'),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  enabled: formUseWeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _youtubeLinkController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'YouTube link (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _startTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Start time (seconds, optional)'),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                _exerciseNameController.clear();
                _secondsController.clear();
                _setsController.clear();
                _repsController.clear();
                _weightController.clear();
                _youtubeLinkController.clear();
                _startTimeController.clear();
                ref.read(exerciseTypeProvider.notifier).set(ExerciseType.timed);
                ref.read(useWeightProvider.notifier).set(false);
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Save'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _routineNameController,
              decoration: const InputDecoration(labelText: 'Routine Name'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New exercise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildExerciseForm(),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (exercises.isEmpty)
                      const Text('No exercises added yet')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                          separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final e = exercises[index];
                          String subtitle;
                          if (e is TimedExercise) {
                            subtitle = 'Timed — ${e.seconds}s';
                          } else {
                            final ce = e as CountingExercise;
                            subtitle = ce.weight != null
                                ? 'Counting — ${ce.sets}x${ce.reps} @ ${ce.weight}kg'
                                : 'Counting — ${ce.sets}x${ce.reps}';
                          }

                          if (e.youtubeUrl != null && e.youtubeUrl!.isNotEmpty) {
                            subtitle = "$subtitle • Video: ${e.youtubeUrl}${e.youtubeStartSeconds != null ? ' @ ${e.youtubeStartSeconds}s' : ''}";
                          }

                          return ListTile(
                            title: Text(e.name),
                            subtitle: Text(subtitle),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeExercise(index),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
