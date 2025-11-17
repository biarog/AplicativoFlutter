import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';
import '../widgets/youtube_player.dart';

class RoutinePlayerScreen extends StatefulWidget {
  final Routine routine;

  const RoutinePlayerScreen({super.key, required this.routine});

  @override
  State<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  int _currentIndex = 0;
  late int _secondsRemaining;
  int? _setsRemaining;
  int? _totalSets;
  Timer? _ticker;
  bool _isPlaying = false;
  bool _awaitingVideo = false;
  bool _videoPlaying = false;

  @override
  void initState() {
    super.initState();
    final ex = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex]
        : null;
    if (ex is TimedExercise) {
      _secondsRemaining = ex.seconds;
      _setsRemaining = null;
      _totalSets = null;
    } else if (ex is CountingExercise) {
      _totalSets = ex.sets;
      _setsRemaining = _totalSets;
      _secondsRemaining = 0;
    } else {
      _secondsRemaining = 0;
      _setsRemaining = null;
      _totalSets = null;
    }
  }

  void _start() {
    final ex = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex]
        : null;
    if (ex is! TimedExercise) return; // only start for timed exercises
    if (_ticker != null) return; // already running

    // If exercise has a YouTube video, either start immediately if it's already playing
    // or wait for the player to begin playback (onPlaybackStateChanged) before starting timer.
    if (ex.youtubeUrl != null && ex.youtubeUrl!.isNotEmpty) {
      setState(() {
        _isPlaying = true; // reflect play intent in UI
      });

      if (_videoPlaying) {
        // video already playing -> start timer now
        setState(() => _awaitingVideo = false);
        _startTimer();
      } else {
        // video not yet playing -> wait for onPlay/onPlayback to trigger start
        setState(() => _awaitingVideo = true);
      }
      return;
    }

    setState(() => _isPlaying = true);
    _startTimer();
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _isPlaying = false;
      _awaitingVideo = false;
    });
  }

  void _startTimer() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining -= 1);
      } else {
        _nextInternal();
      }
    });
  }

  void _nextInternal() {
    _ticker?.cancel();
    if (_currentIndex < widget.routine.exercises.length - 1) {
      setState(() {
        _currentIndex += 1;
        final ex = widget.routine.exercises[_currentIndex];
        if (ex is TimedExercise) {
          _secondsRemaining = ex.seconds;
          _setsRemaining = null;
          _totalSets = null;
        } else if (ex is CountingExercise) {
          _totalSets = ex.sets;
          _setsRemaining = _totalSets;
          _secondsRemaining = 0;
        } else {
          _secondsRemaining = 0;
          _setsRemaining = null;
          _totalSets = null;
        }
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
        final ex = widget.routine.exercises[_currentIndex];
        if (ex is TimedExercise) {
          _secondsRemaining = ex.seconds;
          _setsRemaining = null;
          _totalSets = null;
        } else if (ex is CountingExercise) {
          _totalSets = ex.sets;
          _setsRemaining = _totalSets;
          _secondsRemaining = 0;
        } else {
          _secondsRemaining = 0;
          _setsRemaining = null;
          _totalSets = null;
        }
      });
    } else {
      setState(() {
        final ex = widget.routine.exercises[_currentIndex];
        if (ex is TimedExercise) {
          _secondsRemaining = ex.seconds;
          _setsRemaining = null;
          _totalSets = null;
        } else if (ex is CountingExercise) {
          _totalSets = ex.sets;
          _setsRemaining = _totalSets;
          _secondsRemaining = 0;
        } else {
          _secondsRemaining = 0;
          _setsRemaining = null;
          _totalSets = null;
        }
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
      final ex = widget.routine.exercises.isNotEmpty ? widget.routine.exercises[0] : null;
      if (ex is TimedExercise) {
        _secondsRemaining = ex.seconds;
        _totalSets = null;
        _setsRemaining = null;
      } else if (ex is CountingExercise) {
        _totalSets = ex.sets;
        _setsRemaining = _totalSets;
        _secondsRemaining = 0;
      } else {
        _secondsRemaining = 0;
        _setsRemaining = null;
        _totalSets = null;
      }
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
  final ex = widget.routine.exercises.isNotEmpty ? widget.routine.exercises[_currentIndex] : null;

  double progress() {
    if (ex is TimedExercise) {
      final total = ex.seconds > 0 ? ex.seconds : 1;
      return 1 - (_secondsRemaining / total);
    } else if (ex is CountingExercise) {
      final total = (_totalSets ?? 1);
      final remaining = (_setsRemaining ?? 0);
      if (total <= 0) return 0.0;
      return 1 - (remaining / total);
    }
    return 0.0;
  }

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
              if (ex is TimedExercise) ...[
                Center(
                  child: Text('$_secondsRemaining s', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                // If exercise has a YouTube link, show the player above controls.
                if (ex.youtubeUrl != null && ex.youtubeUrl!.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: YouTubePlayerWidget(
                      url: ex.youtubeUrl!,
                      startAt: Duration(seconds: ex.youtubeStartSeconds ?? 0),
                      autoPlay: _isPlaying,
                      onPlay: () {
                        if (!_awaitingVideo) return;
                        // start timer when video actually begins playback
                        setState(() {
                          _awaitingVideo = false;
                        });
                        _startTimer();
                      },
                      onPlaybackStateChanged: (playing) {
                        // keep track of current playback state so we can start immediately
                        // if user presses start while video is already playing
                        setState(() {
                          _videoPlaying = playing;
                        });
                        if (_awaitingVideo && playing) {
                          setState(() => _awaitingVideo = false);
                          _startTimer();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LinearProgressIndicator(value: progress().clamp(0.0, 1.0)),
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
              ] else if (ex is CountingExercise) ...[
                Center(
                  child: Column(
                    children: [
                      Text('Sets left', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('${_setsRemaining ?? ex.sets}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('${ex.reps} reps', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: progress().clamp(0.0, 1.0)),
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
                    ElevatedButton(
                      onPressed: (_setsRemaining ?? 0) > 0
                          ? () {
                              setState(() {
                                _setsRemaining = (_setsRemaining ?? 0) - 1;
                              });
                              if ((_setsRemaining ?? 0) <= 0) {
                                _nextInternal();
                              }
                            }
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text('Complete set', style: TextStyle(fontSize: 16)),
                      ),
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
              ],
            ] else ...[
              const Center(child: Text('No exercises in this routine')),
            ]
          ],
        ),
      ),
    );
  }
}
