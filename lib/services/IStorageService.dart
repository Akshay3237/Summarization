import '../models/Pair.dart';

abstract class IStorageService{
  Future<Pair<bool, List<String>>> StoreSummaryGeneratedFromText(String text,String summary,String summaryType,int length);
}