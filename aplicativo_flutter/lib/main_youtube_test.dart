import 'package:flutter/material.dart';
import 'screens/youtube_test_screen.dart';

void main() {
  runApp(const MyTestApp());
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Player Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const YouTubeTestScreen(),
    );
  }
}
