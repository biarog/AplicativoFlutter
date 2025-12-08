import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../l10n/app_localizations.dart';

class YouTubePlayerWidget extends ConsumerStatefulWidget {
	final String url;
	final Duration startAt;
	final bool autoPlay;
	final VoidCallback? onPlay;
	final ValueChanged<bool>? onPlaybackStateChanged;

	const YouTubePlayerWidget({super.key, required this.url, this.startAt = Duration.zero, this.autoPlay = false, this.onPlay, this.onPlaybackStateChanged});

	@override
	ConsumerState<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends ConsumerState<YouTubePlayerWidget> {
	late YoutubePlayerController _controller;
	String? _videoId;
	bool _playNotified = false;
	VoidCallback? _controllerListener;

	@override
	void initState() {
		super.initState();
		_videoId = YoutubePlayer.convertUrlToId(widget.url);
		_controller = YoutubePlayerController(
			initialVideoId: _videoId ?? '',
			flags: YoutubePlayerFlags(
				autoPlay: false,
				mute: false,
				startAt: widget.startAt.inSeconds,
			),
		);
		_controllerListener = () {
			final playing = _controller.value.isPlaying;
			// notify parent of any playback state changes
			widget.onPlaybackStateChanged?.call(playing);
			if (playing && !_playNotified) {
				_playNotified = true;
				widget.onPlay?.call();
			}
			if (!playing) {
				// allow future notifications when playback restarts
				_playNotified = false;
			}
		};
		_controller.addListener(_controllerListener!);
		
		// Pre-load video (cue) to improve loading time
		if (_videoId != null && _videoId!.isNotEmpty) {
			_controller.cue(_videoId!, startAt: widget.startAt.inSeconds);
		}
	}

	@override
	void didUpdateWidget(covariant YouTubePlayerWidget oldWidget) {
		super.didUpdateWidget(oldWidget);
		final newId = YoutubePlayer.convertUrlToId(widget.url);
		if (newId != _videoId) {
			_videoId = newId;
			if (_videoId != null && _videoId!.isNotEmpty) {
				// Always use `cue` to pre-load video - autoplay will be controlled separately
				_controller.cue(_videoId!, startAt: widget.startAt.inSeconds);
				if (widget.autoPlay) {
					_controller.play();
				}
			}
		}

		if (oldWidget.startAt != widget.startAt) {
			_controller.seekTo(widget.startAt);
		}

		// Note: We removed autoplay control from didUpdateWidget
		// Video now plays independently of timer state
	}

	@override
	void dispose() {
		if (_controllerListener != null) _controller.removeListener(_controllerListener!);
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		if (_videoId == null || _videoId!.isEmpty) {
			return Center(child: Text(AppLocalizations.of(context)!.invalidYoutubeUrl));
		}

		return YoutubePlayer(
			controller: _controller,
			showVideoProgressIndicator: true,
			progressIndicatorColor: Theme.of(context).colorScheme.primary,
			onReady: () {
				_controller.seekTo(widget.startAt);
				// only start playback if explicitly requested
				if (widget.autoPlay) {
					_controller.play();
				}
			},
		);
	}
}

