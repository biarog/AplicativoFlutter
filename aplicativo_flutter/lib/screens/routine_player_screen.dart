import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../l10n/app_localizations.dart';

import '../models/routine.dart';
import '../providers/completed_routines_provider.dart';
import '../widgets/youtube_player.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RoutinePlayerScreen extends ConsumerStatefulWidget {
  final Routine routine;

  const RoutinePlayerScreen({super.key, required this.routine});

  @override
  ConsumerState<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends ConsumerState<RoutinePlayerScreen> {
  int _currentIndex = 0;
  late int _secondsRemaining;
  int? _setsRemaining;
  int? _totalSets;
  Timer? _ticker;
  bool _isPlaying = false;
  bool _awaitingVideo = false;
  bool _userPaused = false; // Keeps track of manual pauses to avoid auto-starting
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
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

    // Start automatically for timed exercises without videos once the first frame is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoStartIfNoVideo());
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _updateNotification() async {
    if (!_isPlaying) {
      await flutterLocalNotificationsPlugin.cancel(0);
      return;
    }

    final ex = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex]
        : null;
    
    if (ex is TimedExercise) {
      final minutes = _secondsRemaining ~/ 60;
      final seconds = _secondsRemaining % 60;
      final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      
      final l10n = AppLocalizations.of(context)!;
      final androidDetails = AndroidNotificationDetails(
        'routine_timer',
        l10n.routineTimer,
        channelDescription: l10n.routineTimerDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await flutterLocalNotificationsPlugin.show(
        0,
        ex.name,
        l10n.timeRemaining(timeStr),
        details,
      );
    }
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _start() {
    final ex = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex]
        : null;
    if (ex is! TimedExercise) return; // only start for timed exercises
    if (_ticker != null) return; // already running

    _userPaused = false;
    setState(() => _isPlaying = true);
    _startTimer();
  }

  void _pause() {
    _stopTicker();
    setState(() {
      _isPlaying = false;
      _awaitingVideo = false;
    });
    _userPaused = true;
    _updateNotification();
  }

  bool _exerciseHasVideo(Exercise? ex) => (ex?.youtubeUrl?.isNotEmpty ?? false);

  void _autoStartIfNoVideo() {
    final ex = widget.routine.exercises.isNotEmpty
        ? widget.routine.exercises[_currentIndex]
        : null;

    if (ex is TimedExercise && !_exerciseHasVideo(ex) && !_isPlaying && _ticker == null && !_userPaused) {
      _start();
    }
  }

  void _startTimer() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining -= 1);
        _updateNotification();
      } else {
        _playBellSound();
        _nextInternal();
      }
    });
    _updateNotification();
  }

  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/sino.mp3'));
    } catch (e) {
      // Silently fail if audio doesn't play
    }
  }

  void _nextInternal() {
    _stopTicker();
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
      if (_isPlaying) {
        _start();
      } else {
        _autoStartIfNoVideo();
      }
    } else {
      // Routine finished
      _completeRoutine();
    }
  }

  void _prev() {
    _stopTicker();
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
    if (_isPlaying) {
      _start();
    } else {
      _autoStartIfNoVideo();
    }
  }

  Future<void> _completeRoutine() async {
    _pause();
    
    // Marcar rotina como completada usando o novo provider
    await ref.read(completedRoutinesProvider.notifier).markRoutineAsCompleted(
      widget.routine.id,
      DateTime.now(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.routineCompletedMessage(widget.routine.name)),
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
        _userPaused = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _audioPlayer.dispose();
    flutterLocalNotificationsPlugin.cancel(0);
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
              Text(AppLocalizations.of(context)!.exerciseProgress(_currentIndex + 1, widget.routine.exercises.length),
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(ex.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (ex is TimedExercise) ...[
                Center(
                  child: Text(AppLocalizations.of(context)!.secondsShort(_secondsRemaining), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                // If exercise has a YouTube link, show the player above controls.
                if (ex.youtubeUrl != null && ex.youtubeUrl!.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: YouTubePlayerWidget(
                      url: ex.youtubeUrl!,
                      startAt: Duration(seconds: ex.youtubeStartSeconds ?? 0),
                      autoPlay: false, // Video controls are independent of timer
                      onPlay: () {
                        if (!_awaitingVideo) return;
                        // start timer when video actually begins playback
                        setState(() {
                          _awaitingVideo = false;
                        });
                        _startTimer();
                      },
                      onPlaybackStateChanged: (playing) {
                        // Video playback is now independent of timer state
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
                      Text(AppLocalizations.of(context)!.setsLeft, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('${_setsRemaining ?? ex.sets}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.reps(ex.reps), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      if (ex.weight != null) ...[
                        const SizedBox(height: 12),
                        Text('${ex.weight} ${AppLocalizations.of(context)!.weightKg}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ],
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(AppLocalizations.of(context)!.completeSet, style: const TextStyle(fontSize: 16)),
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
                Center(child: Text(AppLocalizations.of(context)!.noExercisesInRoutine)),
              ],
            ] else ...[
              Center(child: Text(AppLocalizations.of(context)!.noExercisesInRoutine)),
            ]
          ],
        ),
      ),
    );
  }
}
