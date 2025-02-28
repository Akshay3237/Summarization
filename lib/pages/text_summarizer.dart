import 'package:flutter/material.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import 'package:textsummarize/services/IStorageService.dart';
import '../models/Pair.dart';
import '../services/ISettingService.dart';
import '../services/ISummarizeService.dart';

class TextSummarizerPage extends StatefulWidget {
  const TextSummarizerPage({Key? key}) : super(key: key);

  @override
  _TextSummarizerPageState createState() => _TextSummarizerPageState();
}

class _TextSummarizerPageState extends State<TextSummarizerPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController(text: "150"); // Default 150
  List<String> _summary = [];
  bool _isLoading = false;
  String _summaryType = "Abstractive"; // Default summarization type

  ISummarizeService summarizeService = Injection.getInstance<ISummarizeService>(
      ISummarizeService.typeName, true);

  final ISettingService _settingService =  Injection.getInstance<ISettingService>(
      ISettingService.typeName, true);
  IStorageService storageService=Injection.getInstance<IStorageService>(IStorageService.typeName, true);
  Future<void> _summarizeText() async {
    String inputText = _textController.text.trim();
    String lengthText = _lengthController.text.trim();
    int maxLength = lengthText.isNotEmpty ? int.tryParse(lengthText) ?? 150 : 150;

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
      Pair<bool, List<String>> result =
      await summarizeService.getSummary(inputText, maxLength, _summaryType);
      bool isStore=await _settingService.isTextSummaryEnabled();
      setState(() {
        _summary = result.first ? result.second : result.second;
      });
      if(result.first){
        if(isStore){
          storageService.storeSummaryGeneratedFromText(text: inputText, summary: _summary, fromWhich: "fromtext", length: maxLength);
        }
      }
    } catch (e) {
      setState(() {
        _summary = ["An error occurred while summarizing."+e.toString()];
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
            Expanded(
              child: SingleChildScrollView(
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
                    TextField(
                      controller: _lengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Summary Length (Default: 150)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 20),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _summarizeText,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Summarize'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
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
