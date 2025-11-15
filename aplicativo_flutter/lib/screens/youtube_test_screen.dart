import 'package:flutter/material.dart';
import '../widgets/youtube_player.dart';

class YouTubeTestScreen extends StatelessWidget {
  const YouTubeTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Player Test')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('Teste do widget YouTubePlayerWidget'),
            const SizedBox(height: 12),
            // Example: starts at 30 seconds
            Expanded(
              child: YouTubePlayerWidget(
                url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                startAt: const Duration(seconds: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
