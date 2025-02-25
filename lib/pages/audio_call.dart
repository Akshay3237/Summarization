import 'package:flutter/material.dart';

import 'audio_summarize.dart';

class AudioCallPage extends StatelessWidget {
  const AudioCallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
      ),
      body: Center(
        child: Text("Audio calling feature is given here")
      ),
    );
  }
}

