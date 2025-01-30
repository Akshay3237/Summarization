import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:textsummarize/dependencies/dependencies.dart';
import 'dart:convert';

import 'package:textsummarize/services/ISummarizeService.dart';

class TextSummarizerPage extends StatefulWidget {
  const TextSummarizerPage({Key? key}) : super(key: key);

  @override
  _TextSummarizerPageState createState() => _TextSummarizerPageState();
}

class _TextSummarizerPageState extends State<TextSummarizerPage> {
  final TextEditingController _textController = TextEditingController();
  String _summary = "";
  bool _isLoading = false;

  final String apiUrl = "https://api.apyhub.com/ai/summarize-url"; // Replace with your API URL
  Isummarizeservice summariseService=Injection.getInstance<Isummarizeservice>(Isummarizeservice.typeName, true);
  Future<void> _summarizeText() async {
    String inputText = _textController.text;

    if (inputText.isEmpty) {
      setState(() {
        _summary = "Please enter text to summarize.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = ""; // Clear the summary while loading
    });

    try {
      // Make the API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': inputText}), // Adjust payload as per your API
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _summary = data['summary'] ?? "No summary returned from the API.";
        });
      } else {
        setState(() {
          _summary = "Failed to summarize text. Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _summary = "An error occurred: $e";
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
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text('Summarize'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _summary,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
