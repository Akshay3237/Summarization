import '../models/Pair.dart';

abstract class IStorageService {
  static const String typeName = "IStorageService";

  Future<Pair<bool, List<String>>> storeSummaryGeneratedFromText({
    required String text,
    required List<String> summary,
    required String fromWhich,
    required int length,
  });

  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromText();

  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromVoice();

  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromVideoCall();

  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromAudioCall();

  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromImage();

  Future<bool> deleteStorageByStorageId({
    required String storageId,
  });

  Future<Pair<bool, List<String>>> getAllStorage();
  Future<bool> deleteAllStorage();
}
