import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine.dart';
import '../providers/local_routines_provider.dart';
import '../l10n/app_localizations.dart';
import './create_routine_screen.dart';

class EditRoutineScreen extends ConsumerStatefulWidget {
  final Routine routine;

  const EditRoutineScreen({super.key, required this.routine});

  @override
  ConsumerState<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends ConsumerState<EditRoutineScreen> {
  final _routineNameController = TextEditingController();

  final _exerciseNameController = TextEditingController();
  final _secondsController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  final _startTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _routineNameController.text = widget.routine.name;
    
    // Initialize the exercise providers with the current routine's exercises
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exercisesProvider.notifier).setList(widget.routine.exercises);
    });
  }

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

  Future<void> _updateRoutine() async {
    final name = _routineNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.routineNameRequired)),
      );
      return;
    }

    final exercises = ref.read(exercisesProvider);
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.atLeastOneExercise)),
      );
      return;
    }

    final updatedRoutine = Routine(
      id: widget.routine.id,
      name: name,
      exercises: exercises,
    );

    try {
      // Update locally
      await ref.read(localRoutinesProvider.notifier).updateRoutine(updatedRoutine);

      // Update in Firebase if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final routinesRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('routines')
            .doc(updatedRoutine.id);

        await routinesRef.update({
          'name': updatedRoutine.name,
          'exercises': updatedRoutine.exercises.map((e) => e.toJson()).toList(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.routineSaved)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToSaveRoutine(e.toString()))),
      );
    }
  }

  void _addExercise(Exercise exercise) {
    ref.read(exercisesProvider.notifier).addExercise(exercise);
    _clearFields();
  }

  void _removeExercise(int index) {
    ref.read(exercisesProvider.notifier).removeAt(index);
  }

  void _clearFields() {
    _exerciseNameController.clear();
    _secondsController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _youtubeLinkController.clear();
    _startTimeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    final exerciseType = ref.watch(exerciseTypeProvider);
    final useWeight = ref.watch(useWeightProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRoutine),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _routineNameController,
                    decoration: InputDecoration(labelText: l10n.routineName),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateRoutine,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 3,
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.exercises, style: Theme.of(context).textTheme.headlineSmall),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearFields,
                          tooltip: l10n.clear,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _exerciseNameController,
                      decoration: InputDecoration(labelText: l10n.exerciseName),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.exerciseType),
                        SegmentedButton<ExerciseType>(
                          segments: [
                            ButtonSegment(
                              value: ExerciseType.timed,
                              label: Text(l10n.timed),
                            ),
                            ButtonSegment(
                              value: ExerciseType.counting,
                              label: Text(l10n.counting),
                            ),
                          ],
                          selected: {exerciseType},
                          onSelectionChanged: (Set<ExerciseType> newSelection) {
                            ref.read(exerciseTypeProvider.notifier).set(newSelection.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (exerciseType == ExerciseType.timed) ...[
                      TextField(
                        controller: _secondsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.durationSeconds),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _setsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: l10n.sets),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: l10n.repsPerSet),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.useWeight),
                          Switch(
                            value: useWeight,
                            onChanged: (value) => ref.read(useWeightProvider.notifier).set(value),
                          ),
                        ],
                      ),
                      if (useWeight) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.weight),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _youtubeLinkController,
                      decoration: InputDecoration(labelText: l10n.youtubeLinkOptional),
                    ),
                    if (_youtubeLinkController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _startTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.startTimeOptional),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final name = _exerciseNameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.exerciseNameRequired)),
                          );
                          return;
                        }

                        if (exerciseType == ExerciseType.timed) {
                          final secondsText = _secondsController.text.trim();
                          if (secondsText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.validDurationRequired)),
                            );
                            return;
                          }
                          final seconds = int.parse(secondsText);
                          final youtubeUrl = _youtubeLinkController.text.isEmpty ? null : _youtubeLinkController.text.trim();
                          final startSeconds = _startTimeController.text.isEmpty ? null : int.parse(_startTimeController.text.trim());

                          _addExercise(TimedExercise(
                            name: name,
                            seconds: seconds,
                            youtubeUrl: youtubeUrl,
                            youtubeStartSeconds: startSeconds,
                          ));
                        } else {
                          final setsText = _setsController.text.trim();
                          final repsText = _repsController.text.trim();
                          if (setsText.isEmpty || repsText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.validSetsRepsRequired)),
                            );
                            return;
                          }
                          final sets = int.parse(setsText);
                          final reps = int.parse(repsText);
                          final weight = useWeight && _weightController.text.isNotEmpty
                              ? double.parse(_weightController.text.trim())
                              : null;

                          if (useWeight && weight == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.validWeightRequired)),
                            );
                            return;
                          }

                          _addExercise(CountingExercise(
                            name: name,
                            sets: sets,
                            reps: reps,
                            weight: weight,
                          ));
                        }
                      },
                      child: Text(l10n.addExercise),
                    ),
                    const SizedBox(height: 24),
                    if (exercises.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final e = exercises[index];
                          String subtitle;
                          if (e is TimedExercise) {
                            subtitle = '${l10n.timed} — ${l10n.secondsShort(e.seconds)}';
                          } else {
                            final ce = e as CountingExercise;
                            subtitle = ce.weight != null
                                ? '${l10n.counting} — ${ce.sets}x${ce.reps} @ ${ce.weight}kg'
                                : '${l10n.counting} — ${ce.sets}x${ce.reps}';
                          }

                          if (e.youtubeUrl != null && e.youtubeUrl!.isNotEmpty) {
                            subtitle = "$subtitle • Video: ${e.youtubeUrl}${e.youtubeStartSeconds != null ? ' @ ${l10n.secondsShort(e.youtubeStartSeconds!)}' : ''}";
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
