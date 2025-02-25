import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:textsummarize/dependencies/dependencies.dart';
import '../models/Pair.dart';
import '../services/ISummarizeService.dart';

class AudioSummarize extends StatefulWidget {
  @override
  _AudioSummarizeState createState() => _AudioSummarizeState();
}

class _AudioSummarizeState extends State<AudioSummarize> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String textListened = ""; // Stores all spoken text
  final TextEditingController _lengthController = TextEditingController(text: "150");
  String _summaryType = "Abstractive"; // Default summary type
  List<String> _summary = [];
  bool _isLoading = false;

  ISummarizeService summarizeService = Injection.getInstance<ISummarizeService>(
      ISummarizeService.typeName, true);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  /// Start Listening
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            textListened= result.recognizedWords; // Append text
          });
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      );
    }
  }

  /// Stop Listening
  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  /// Summarize Transcribed Text
  Future<void> _summarizeText() async {
    String lengthText = _lengthController.text.trim();
    int maxLength = lengthText.isNotEmpty ? int.tryParse(lengthText) ?? 150 : 150;

    if (textListened.isEmpty) {
      setState(() {
        _summary = ["No text available to summarize."];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = [];
    });

    try {
      Pair<bool, List<String>> result = await summarizeService.getSummary(
          textListened, maxLength, _summaryType);

      setState(() {
        _summary = result.second;
      });
    } catch (e) {
      setState(() {
        _summary = ["Error occurred during summarization."];
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
      appBar: AppBar(title: Text("Audio Summarizer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display Transcribed Text
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        textListened.isEmpty ? "Press Start and speak..." : textListened,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Summary Length Input
                    TextField(
                      controller: _lengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Summary Length (Default: 150)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Summary Type Selector
                    const Text("Summarization Type:"),
                    Row(
                      children: [
                        Radio(
                          value: "Extractive",
                          groupValue: _summaryType,
                          onChanged: (value) {
                            setState(() {
                              _summaryType = value.toString();
                            });
                          },
                        ),
                        const Text("Extractive"),
                        SizedBox(width: 20),
                        Radio(
                          value: "Abstractive",
                          groupValue: _summaryType,
                          onChanged: (value) {
                            setState(() {
                              _summaryType = value.toString();
                            });
                          },
                        ),
                        const Text("Abstractive"),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Summarize Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _summarizeText,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Summarize'),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Summary Output
            Expanded(
              child: _summary.isNotEmpty
                  ? ListView.builder(
                itemCount: _summary.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "- ${_summary[index]}",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              )
                  : Center(child: Text("Your summary will appear here.")),
            ),

            // Start/Stop Listening Button
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              backgroundColor: _isListening ? Colors.red : Colors.green,
              child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
