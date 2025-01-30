import '../models/Pair.dart';

abstract class Isummarizeservice{
  static const String typeName = "ISummarizeService";

  Future<Pair<bool,Object>> getSummary();

}