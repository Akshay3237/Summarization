import 'package:textsummarize/services/ISummarizeService.dart';
import '../models/Pair.dart';

class SummarizeService implements Isummarizeservice {
  @override
  Future<Pair<bool, Object>> getSummary() async {
    try {
      // Simulate fetching or processing a summary.
      final summary = "This is a summarized text.";
      return Pair(true, summary); // Returning success with the summary text.
    } catch (e) {
      return Pair(false, "An error occurred while summarizing: ${e.toString()}");
    }
  }
}