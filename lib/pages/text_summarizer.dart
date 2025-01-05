import 'package:flutter/material.dart';

class TextSummarizerPage extends StatelessWidget {
  const TextSummarizerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Summarizer'),
      ),
      body: const Center(
        child: Text(
          'Hello, I am Text Summarizer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}