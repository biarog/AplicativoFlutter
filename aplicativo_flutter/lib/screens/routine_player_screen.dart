import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutinePlayerScreen extends StatefulWidget {
  final Routine routine;

  const RoutinePlayerScreen({super.key, required this.routine});

  @override
  State<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  int _currentIndex = 0;
  late int _secondsRemaining;
  Timer? _ticker;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex].seconds
        : 0;
  }

  void _start() {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining -= 1);
      } else {
        _nextInternal();
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;
    setState(() => _isPlaying = false);
  }

  void _nextInternal() {
    _ticker?.cancel();
    if (_currentIndex < widget.routine.exercises.length - 1) {
      setState(() {
        _currentIndex += 1;
        _secondsRemaining = widget.routine.exercises[_currentIndex].seconds;
      });
      if (_isPlaying) _start();
    } else {
      // Routine finished
      _completeRoutine();
    }
  }

  void _prev() {
    _ticker?.cancel();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
        _secondsRemaining = widget.routine.exercises[_currentIndex].seconds;
      });
    } else {
      setState(() {
        _secondsRemaining = widget.routine.exercises[_currentIndex].seconds;
      });
    }
    if (_isPlaying) _start();
  }

  Future<void> _completeRoutine() async {
    _pause();
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_dates_${widget.routine.id}';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final list = prefs.getStringList(key) ?? <String>[];
    if (!list.contains(today)) {
      list.add(today);
      await prefs.setStringList(key, list);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Routine "${widget.routine.name}" completed and marked on calendar.'),
    ));
    // Reset to start
    setState(() {
      _currentIndex = 0;
      _secondsRemaining = widget.routine.exercises.isNotEmpty
          ? widget.routine.exercises[0].seconds
          : 0;
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final ex = widget.routine.exercises.isNotEmpty
    ? widget.routine.exercises[_currentIndex]
    : null;

  final totalForCurrent = ex?.seconds ?? 1;
  final progress = 1 - (_secondsRemaining / totalForCurrent);

    return Scaffold(
      appBar: AppBar(title: Text(widget.routine.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ex != null) ...[
              Text('Exercise ${_currentIndex + 1} of ${widget.routine.exercises.length}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(ex.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Center(
                child: Text('$_secondsRemaining s', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _prev,
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 36,
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _isPlaying ? _pause : _start,
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _nextInternal,
                    icon: const Icon(Icons.skip_next),
                    iconSize: 36,
                  ),
                ],
              ),
            ] else ...[
              const Center(child: Text('No exercises in this routine')),
            ]
          ],
        ),
      ),
    );
  }
}
