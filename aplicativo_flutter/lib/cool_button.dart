import 'package:flutter/material.dart';

void main() {
  runApp(const CoolButton());
}

class CoolButton extends StatelessWidget {
  const CoolButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cool Button'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Press Me'),
          ),
        ),
      ),
    );
  }
}