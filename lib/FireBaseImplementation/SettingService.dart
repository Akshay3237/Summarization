import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ISettingService.dart';


class FireBaseSettingService extends ISettingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Get current user's ID**
  String? get _userId => _auth.currentUser?.uid;

  /// **Get the user's settings from Firestore**
  @override
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      if (_userId == null) return null;

      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection('settings').doc(_userId).get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print("🔥 Error fetching settings: $e");
      return null;
    }
  }

  /// **Check if the user's settings exist**
  @override
  Future<bool> settingsExist() async {
    return (await getSettings()) != null;
  }

  /// **Save or update the user's settings in Firestore**
  @override
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      if (_userId == null) return false;

      await _firestore.collection('settings').doc(_userId).set(settings, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("🔥 Error saving settings: $e");
      return false;
    }
  }

  /// **Check if storing video call summary is enabled**
  @override
  Future<bool> isVideoCallSummaryEnabled() async {
    return await _getBoolSetting("store_video_call_summary");
  }

  /// **Check if storing audio call summary is enabled**
  @override
  Future<bool> isAudioCallSummaryEnabled() async {
    return await _getBoolSetting("store_audio_call_summary");
  }

  /// **Check if storing text summary is enabled**
  @override
  Future<bool> isTextSummaryEnabled() async {
    return await _getBoolSetting("store_text_summary");
  }

  /// **Check if storing audio summary is enabled**
  @override
  Future<bool> isAudioSummaryEnabled() async {
    return await _getBoolSetting("store_audio_summary");
  }

  /// **Check if storing image summary is enabled**
  @override
  Future<bool> isImageSummaryEnabled() async {
    return await _getBoolSetting("store_image_summary");
  }


  /// **Get video summary type (Extractive/Abstractive)**
  @override
  Future<String> getVideoSummaryType() async {
    return await _getStringSetting("video_summary_type", "Abstractive");
  }

  /// **Get audio summary type (Extractive/Abstractive)**
  @override
  Future<String> getAudioSummaryType() async {
    return await _getStringSetting("audio_summary_type", "Abstractive");
  }

  /// **Get video summary length**
  @override
  Future<int> getVideoSummaryLength() async {
    return await _getIntSetting("video_summary_length", 150);
  }

  /// **Get audio summary length**
  @override
  Future<int> getAudioSummaryLength() async {
    return await _getIntSetting("audio_summary_length", 150);
  }

  /// **Helper method: Get a boolean setting**
  Future<bool> _getBoolSetting(String key) async {
    Map<String, dynamic>? settings = await getSettings();
    // print(settings);
    return settings?[key] ?? false;
  }

  /// **Helper method: Get a string setting with a default value**
  Future<String> _getStringSetting(String key, String defaultValue) async {
    Map<String, dynamic>? settings = await getSettings();
    return settings?[key] ?? defaultValue;
  }

  /// **Helper method: Get an integer setting with a default value**
  Future<int> _getIntSetting(String key, int defaultValue) async {
    Map<String, dynamic>? settings = await getSettings();
    return settings?[key] ?? defaultValue;
  }
}
