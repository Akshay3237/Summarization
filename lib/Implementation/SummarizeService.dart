import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Pair.dart';
import 'package:textsummarize/services/ISummarizeService.dart';

class SummarizeService implements ISummarizeService {
  final String apiUrl = 'https://your-api-url.com/v2/summarization'; // Replace with your API URL

  @override
  Future<Pair<bool, List<String>>> getSummary(String text) async {
    try {
      // Send the text to the API for summarization
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text,
        }),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response to get the summary (adjust the response structure as per your API)
        var data = json.decode(response.body);
        String summary = data['summary'] ?? ''; // Assuming the API returns a 'summary' field

        // Split the summary into sentences
        List<String> summaryList = summary.split('. ').where((s) => s.isNotEmpty).toList();
        return Pair(true, summaryList);
      } else {
        // Handle the error if the request fails
        return Pair(false, ["Error: Failed to fetch summary from API."]);
      }
    } catch (e) {
      // Catch any exception and return a failure response
      return Pair(false, ["Error: Failed to summarize text."]);
    }
  }
}
