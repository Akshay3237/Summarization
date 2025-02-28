import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Pair.dart';
import '../services/IStorageService.dart';

class FireBaseStorageService implements IStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<Pair<bool, List<String>>> storeSummaryGeneratedFromText({
    required String text,
    required List<String> summary,
    required String fromWhich,
    required int length,
  }) async {
    if (_userId == null) return Pair(false, ["User not logged in"]);

    try {
      Map<String, dynamic> summaryData = {
        "u_id": _userId,
        "text": text,
        "summary": summary.join(". "),
        "fromWhich": fromWhich,
        "date": Timestamp.now(),
      };

      await _firestore.collection("summarygenerated").add(summaryData);
      return Pair(true, ["Summary stored successfully"]);
    } catch (e) {
      print("Error storing summary: $e");
      return Pair(false, ["Error storing summary"]);
    }
  }

  Future<Pair<bool, List<String>>> _getStorageByType(String type) async {
    if (_userId == null) return Pair(false, ["User not logged in"]);

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("summarygenerated")
          .where("u_id", isEqualTo: _userId)
          .where("fromWhich", isEqualTo: type)
          .orderBy("date", descending: true) // Sorting by timestamp
          .get();

      List<String> summaries = querySnapshot.docs
          .map((doc) => doc["summary"] as String)
          .toList();

      return Pair(true, summaries);
    } catch (e) {
      print("Error fetching summaries: $e");
      return Pair(false, ["Error fetching summaries"]);
    }
  }

  @override
  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromText() =>
      _getStorageByType("fromtext");

  @override
  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromVoice() =>
      _getStorageByType("fromaudio");

  @override
  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromVideoCall() =>
      _getStorageByType("fromvideocall");

  @override
  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromAudioCall() =>
      _getStorageByType("fromaudiocall");

  @override
  Future<Pair<bool, List<String>>> getStorageBasedOnSummaryFromImage() =>
      _getStorageByType("fromimage");

  @override
  Future<Pair<bool, List<String>>> getAllStorage() async {
    if (_userId == null) return Pair(false, ["User not logged in"]);

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("summarygenerated")
          .where("u_id", isEqualTo: _userId)
          .orderBy("date", descending: true) // Sorting by timestamp
          .get();

      List<String> summaries = querySnapshot.docs
          .map((doc) => doc["summary"] as String)
          .toList();

      return Pair(true, summaries);
    } catch (e) {
      print("Error fetching all summaries: $e");
      return Pair(false, ["Error fetching all summaries"]);
    }
  }
  @override
  Future<bool> deleteStorageByStorageId({
    required String storageId,
  }) async {
    if (_userId == null) return false;

    try {
      DocumentSnapshot doc =
      await _firestore.collection("summarygenerated").doc(storageId).get();

      if (doc.exists && doc["u_id"] == _userId) {
        await _firestore.collection("summarygenerated").doc(storageId).delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting summary: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteAllStorage() async {
    if (_userId == null) return false;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("summarygenerated")
          .where("u_id", isEqualTo: _userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection("summarygenerated").doc(doc.id).delete();
      }

      return true;
    } catch (e) {
      print("Error deleting all summaries: $e");
      return false;
    }
  }
}
