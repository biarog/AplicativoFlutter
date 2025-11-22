import 'package:aplicativo_flutter/models/routine.dart';

/// Example routine used by Widgetbook stories and tests.
/// Keep this small and deterministic so Widgetbook can render the
/// `RoutinePlayerScreen` without any external dependencies.
final Routine sampleRoutine = Routine(
	id: 'routine_1',
	name: 'Full Body Quick',
	exercises: [
		TimedExercise(name: 'Jumping Jacks', seconds: 30),
		CountingExercise(name: 'Push Ups', sets: 3, reps: 10, weight: null),
		TimedExercise(name: 'Plank', seconds: 45),
	],
);

/// A helper that returns a copy of [sampleRoutine] with a different id.
Routine sampleRoutineWithId(String id) => Routine(
			id: id,
			name: sampleRoutine.name,
			exercises: List<Exercise>.from(sampleRoutine.exercises),
		);

/// Small factory to produce a timed-only routine for quick previews.
Routine quickTimedRoutine({int seconds = 20}) => Routine(
			id: 'timed_${seconds}s',
			name: 'Quick ${seconds}s Routine',
			exercises: [TimedExercise(name: 'Work', seconds: seconds)],
		);
