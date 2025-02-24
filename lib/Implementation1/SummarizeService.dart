import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Pair.dart';
import 'package:textsummarize/services/ISummarizeService.dart';

class SummarizeService implements ISummarizeService {
  final String apiUrl = 'http://127.0.0.1:5000/summarize'; // Flask API URL

  @override
  Future<Pair<bool, List<String>>> getSummary(String text, int maxLength, String summaryType) async {
    try {
      // Send the text to the Flask API for summarization
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text, // Sending only text to API
        }),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response to get the summary
        var data = json.decode(response.body);
        String summary = data['summary'] ?? ''; // Ensure 'summary' exists

        // Split the summary into sentences
        List<String> summaryList = summary.split('. ').where((s) => s.isNotEmpty).toList();
        return Pair(true, summaryList);
      } else {
        // Handle error response
        return Pair(false, ["Error: Failed to fetch summary from API. Status: ${response.statusCode}"]);
      }
    } catch (e) {
      // Catch any exception and return an error message
      return Pair(false, ["Error: ${e.toString()}"]);
    }
  }
}
