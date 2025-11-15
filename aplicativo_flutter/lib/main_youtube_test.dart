import 'package:flutter/material.dart';
import 'screens/youtube_test_screen.dart';

void main() {
  runApp(const MyTestApp());
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Player Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const YouTubeTestScreen(),
    );
  }
}
