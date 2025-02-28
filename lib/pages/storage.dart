import 'package:flutter/material.dart';
import '../dependencies/dependencies.dart';
import '../models/Pair.dart';
import '../services/IStorageService.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final IStorageService _storageService =
  Injection.getInstance<IStorageService>(IStorageService.typeName, true);

  List<String> summaries = [];
  String selectedType = "All";
  bool isLoading = false;

  void _fetchSummaries({String? type}) async {
    setState(() => isLoading = true);
    Pair<bool, List<String>> result;

    if (type == null || type == "All") {
      result = await _storageService.getAllStorage();
    } else {
      switch (type) {
        case "Text":
          result = await _storageService.getStorageBasedOnSummaryFromText();
          break;
        case "Voice":
          result = await _storageService.getStorageBasedOnSummaryFromVoice();
          break;
        case "Video Call":
          result = await _storageService.getStorageBasedOnSummaryFromVideoCall();
          break;
        case "Audio Call":
          result = await _storageService.getStorageBasedOnSummaryFromAudioCall();
          break;
        case "Image":
          result = await _storageService.getStorageBasedOnSummaryFromImage();
          break;
        default:
          result = Pair(false, ["Invalid Type"]);
      }
    }

    setState(() {
      isLoading = false;
      selectedType = type ?? "All";
      summaries = result.first ? result.second : ["Error fetching data"];
    });
  }

  void _deleteAllSummaries() async {
    bool success = await _storageService.deleteAllStorage();
    if (success) {
      setState(() => summaries = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All summaries deleted")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete summaries")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSummaries();
  }

  void _showFullSummary(String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Summary Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Summary: $summary"),
            const SizedBox(height: 10),
            Text("Type: $selectedType"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: Column(
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              _buildFetchButton("Show All", "All"),
              _buildFetchButton("Text", "Text"),
              _buildFetchButton("Voice", "Voice"),
              _buildFetchButton("Video Call", "Video Call"),
              _buildFetchButton("Audio Call", "Audio Call"),
              _buildFetchButton("Image", "Image"),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _deleteAllSummaries,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete All"),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : summaries.isEmpty
                ? const Center(child: Text("No summaries found"))
                : ListView.builder(
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                String shortText = summaries[index].length > 20
                    ? "${summaries[index].substring(0, 20)}..."
                    : summaries[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(shortText),
                    onTap: () => _showFullSummary(summaries[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFetchButton(String label, String type) {
    return ElevatedButton(
      onPressed: () => _fetchSummaries(type: type),
      child: Text(label),
    );
  }
}
