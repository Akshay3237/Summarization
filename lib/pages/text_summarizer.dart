import 'package:flutter/material.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import '../models/Pair.dart';
import '../services/ISummarizeService.dart';

class TextSummarizerPage extends StatefulWidget {
  const TextSummarizerPage({Key? key}) : super(key: key);

  @override
  _TextSummarizerPageState createState() => _TextSummarizerPageState();
}

class _TextSummarizerPageState extends State<TextSummarizerPage> {
  final TextEditingController _textController = TextEditingController();
  List<String> _summary = [];
  bool _isLoading = false;

  ISummarizeService summarizeService = Injection.getInstance<ISummarizeService>(
      ISummarizeService.typeName, true);

  Future<void> _summarizeText() async {
    String inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _summary = ["Please enter text to summarize."];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = [];
    });

    try {
      Pair<bool, List<String>> result = await summarizeService.getSummary(inputText);
      setState(() {
        _summary = result.first ? result.second : ["Error: Summarization failed."];
      });
    } catch (e) {
      setState(() {
        _summary = ["An error occurred while summarizing."];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Summarizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Enter text to summarize',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _summarizeText,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Summarize'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _summary.isNotEmpty
                  ? ListView.builder(
                itemCount: _summary.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "- ${_summary[index]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              )
                  : const Center(child: Text("Your summary will appear here.")),
            ),
          ],
        ),
      ),
    );
  }
}
