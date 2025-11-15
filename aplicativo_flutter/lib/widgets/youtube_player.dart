import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerWidget extends StatefulWidget {
	final String url;
	final Duration startAt;

	const YouTubePlayerWidget({Key? key, required this.url, this.startAt = Duration.zero}) : super(key: key);

	@override
	State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
	late YoutubePlayerController _controller;
	String? _videoId;

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
	}

	@override
	void didUpdateWidget(covariant YouTubePlayerWidget oldWidget) {
		super.didUpdateWidget(oldWidget);
		final newId = YoutubePlayer.convertUrlToId(widget.url);
		if (newId != _videoId) {
			_videoId = newId;
			if (_videoId != null && _videoId!.isNotEmpty) {
				_controller.load(_videoId!);
			}
		}

		if (oldWidget.startAt != widget.startAt) {
			_controller.seekTo(widget.startAt);
		}
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		if (_videoId == null || _videoId!.isEmpty) {
			return const Center(child: Text('URL do YouTube inválida'));
		}

		return YoutubePlayer(
			controller: _controller,
			showVideoProgressIndicator: true,
			progressIndicatorColor: Colors.red,
			onReady: () {
				_controller.seekTo(widget.startAt);
			},
		);
	}
}

