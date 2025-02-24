import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Pair.dart';
import 'package:textsummarize/services/ISummarizeService.dart';

class SummarizeGeminiService implements ISummarizeService {
  final String Url= dotenv.env['BASE_URL']??"";
  final String key=dotenv.env['API_KEY']??"";


  @override
  Future<Pair<bool, List<String>>> getSummary(String text, int maxLength, String summaryType) async {
    final String apiUrl;
    if(Url.isNotEmpty){
      apiUrl ="$Url?key=$key";
    }
    else{
      apiUrl="";
    }

    try {
      // Sending the request to the API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": "Assume Maximum number of words=$maxLength and summary type is $summaryType and Summarize this text' : $text '"}
              ]
            }
          ]
        }),
      );

      // Checking if the response is successful
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Extracting the summarized text from the response
        String summary = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";

        if (summary.isNotEmpty) {
          // Splitting the summary into sentences
          List<String> summaryList = summary.split('. ').where((s) => s.isNotEmpty).toList();
          return Pair(true, summaryList);
        } else {
          return Pair(false, ["Error: Summary is empty"]);
        }
      } else {
        return Pair(false, ["Error: API request failed with status ${response.statusCode}"]);
      }
    } catch (e) {
      return Pair(false, ["Error: ${e.toString()}"]);
    }
  }
}
