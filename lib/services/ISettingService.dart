abstract class ISettingService {

  static const String typeName = "ISettingService";
  /// Fetch settings for the current user from Firestore.
  Future<Map<String, dynamic>?> getSettings();

  /// Create or update settings for the current user.
  Future<bool> saveSettings(Map<String, dynamic> settings);

  /// Checks if settings exist for the current user.
  Future<bool> settingsExist();

  /// Checks if storing video call summary is enabled.
  Future<bool> isVideoCallSummaryEnabled();

  /// Checks if storing audio call summary is enabled.
  Future<bool> isAudioCallSummaryEnabled();

  /// Checks if storing text summary is enabled.
  Future<bool> isTextSummaryEnabled();

  /// Checks if storing audio summary is enabled.
  Future<bool> isAudioSummaryEnabled();

  /// Checks if storing image summary is enabled.
  Future<bool> isImageSummaryEnabled();

  /// Gets the summary type for video calls (Extractive/Abstractive).
  Future<String> getVideoSummaryType();

  /// Gets the summary type for audio calls (Extractive/Abstractive).
  Future<String> getAudioSummaryType();

  /// Gets the summary length for video calls.
  Future<int> getVideoSummaryLength();

  /// Gets the summary length for audio calls.
  Future<int> getAudioSummaryLength();
}
