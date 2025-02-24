import '../models/Pair.dart';

abstract class ISummarizeService {
  static const String typeName = "ISummarizeService";

  Future<Pair<bool, List<String>>> getSummary(String text, int maxLength, String summaryType);

}
