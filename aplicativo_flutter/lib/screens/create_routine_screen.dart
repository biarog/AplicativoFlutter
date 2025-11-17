import 'package:flutter/material.dart';

import '../models/routine.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

enum _ExerciseType { timed, counting }

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _routineNameController = TextEditingController();

  final _exerciseNameController = TextEditingController();
  final _secondsController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  final _startTimeController = TextEditingController();

  _ExerciseType _exerciseType = _ExerciseType.timed;
  bool _useWeight = false;

  final List<Exercise> _exercises = [];

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

    if (_exerciseType == _ExerciseType.timed) {
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

        _exercises.add(TimedExercise(name: name, seconds: seconds, youtubeUrl: youtube, youtubeStartSeconds: start));
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
      if (_useWeight) {
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

      _exercises.add(CountingExercise(
        name: name,
        sets: sets,
        reps: reps,
        weight: weight,
        youtubeUrl: youtube,
        youtubeStartSeconds: start,
      ));
    }

    // Clear exercise inputs
    _exerciseNameController.clear();
    _secondsController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _youtubeLinkController.clear();
    _startTimeController.clear();
    _useWeight = false;
    _exerciseType = _ExerciseType.timed;

    setState(() {});
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  void _saveRoutine() {
    final name = _routineNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Routine name is required'),
      ));
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one exercise to the routine'),
      ));
      return;
    }

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      exercises: List.of(_exercises),
    );

    Navigator.of(context).pop(routine);
  }

  Widget _buildExerciseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _exerciseNameController,
          decoration: const InputDecoration(labelText: 'Exercise name'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<_ExerciseType>(
          initialValue: _exerciseType,
          decoration: const InputDecoration(labelText: 'Exercise type'),
          items: const [
            DropdownMenuItem(value: _ExerciseType.timed, child: Text('Timed')),
            DropdownMenuItem(value: _ExerciseType.counting, child: Text('Counting')),
          ],
          onChanged: (_ExerciseType? v) => setState(() {
            if (v != null) _exerciseType = v;
          }),
        ),
        const SizedBox(height: 8),
        if (_exerciseType == _ExerciseType.timed) ...[
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
                value: _useWeight,
                onChanged: (v) => setState(() => _useWeight = v ?? false),
              ),
              const Text('Use weight'),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  enabled: _useWeight,
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
                setState(() {
                  _useWeight = false;
                  _exerciseType = _ExerciseType.timed;
                });
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
                    if (_exercises.isEmpty)
                      const Text('No exercises added yet')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exercises.length,
                          separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final e = _exercises[index];
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
