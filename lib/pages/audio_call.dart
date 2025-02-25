import 'package:flutter/material.dart';

class AudioCallPage extends StatelessWidget {
  const AudioCallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
      ),
      body: const Center(
        child: Text(
          'Hello, I am Audio Caller',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

