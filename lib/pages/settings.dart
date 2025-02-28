import 'package:flutter/material.dart';
import '../dependencies/dependencies.dart';
import '../services/ISettingService.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final ISettingService _settingService =  Injection.getInstance<ISettingService>(
      ISettingService.typeName, true);

  bool _storeVideoCallSummary = false;
  bool _storeAudioCallSummary = false;
  bool _storeTextSummary = false;
  bool _storeAudioSummary = false;
  bool _storeImageSummary = false;

  String _videoSummaryType = "Abstractive";
  String _audioSummaryType = "Abstractive";

  final TextEditingController _videoSummaryLengthController = TextEditingController();
  final TextEditingController _audioSummaryLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// **Load user settings from Firestore**
  Future<void> _loadSettings() async {
    var settings = await _settingService.getSettings();
    if (settings != null) {
      setState(() {
        _storeVideoCallSummary = settings['store_video_call_summary'] ?? false;
        _videoSummaryLengthController.text = (settings['video_summary_length'] ?? 150).toString();
        _videoSummaryType = settings['video_summary_type'] ?? "Abstractive";

        _storeAudioCallSummary = settings['store_audio_call_summary'] ?? false;
        _audioSummaryLengthController.text = (settings['audio_summary_length'] ?? 150).toString();
        _audioSummaryType = settings['audio_summary_type'] ?? "Abstractive";

        _storeTextSummary = settings['store_text_summary'] ?? false;
        _storeAudioSummary = settings['store_audio_summary'] ?? false;
        _storeImageSummary = settings['store_image_summary'] ?? false;
      });
    } else {
      await _saveSettings(isFirstTime: true);
    }
  }

  /// **Save or update settings in Firestore**
  Future<void> _saveSettings({bool isFirstTime = false}) async {
    Map<String, dynamic> settingsData = {
      'store_video_call_summary': _storeVideoCallSummary,
      'video_summary_length': int.tryParse(_videoSummaryLengthController.text) ?? 150,
      'video_summary_type': _videoSummaryType,
      'store_audio_call_summary': _storeAudioCallSummary,
      'audio_summary_length': int.tryParse(_audioSummaryLengthController.text) ?? 150,
      'audio_summary_type': _audioSummaryType,
      'store_text_summary': _storeTextSummary,
      'store_audio_summary': _storeAudioSummary,
      'store_image_summary': _storeImageSummary,
    };

    await _settingService.saveSettings(settingsData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Video Call Summary Storage**
              CheckboxListTile(
                title: const Text("Store Video Call Summary"),
                value: _storeVideoCallSummary,
                onChanged: (value) {
                  setState(() {
                    _storeVideoCallSummary = value ?? false;
                    _saveSettings();
                  });
                },
              ),
              if (_storeVideoCallSummary) ...[
                const Text("Summary Length:"),
                TextField(
                  controller: _videoSummaryLengthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => _saveSettings(),
                ),
                const SizedBox(height: 10),
                const Text("Summary Type:"),
                Row(
                  children: [
                    Radio(
                      value: "Extractive",
                      groupValue: _videoSummaryType,
                      onChanged: (value) {
                        setState(() {
                          _videoSummaryType = value.toString();
                          _saveSettings();
                        });
                      },
                    ),
                    const Text("Extractive"),
                    const SizedBox(width: 20),
                    Radio(
                      value: "Abstractive",
                      groupValue: _videoSummaryType,
                      onChanged: (value) {
                        setState(() {
                          _videoSummaryType = value.toString();
                          _saveSettings();
                        });
                      },
                    ),
                    const Text("Abstractive"),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // **Audio Call Summary Storage**
              CheckboxListTile(
                title: const Text("Store Audio Call Summary"),
                value: _storeAudioCallSummary,
                onChanged: (value) {
                  setState(() {
                    _storeAudioCallSummary = value ?? false;
                    _saveSettings();
                  });
                },
              ),
              if (_storeAudioCallSummary) ...[
                const Text("Summary Length:"),
                TextField(
                  controller: _audioSummaryLengthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => _saveSettings(),
                ),
                const SizedBox(height: 10),
                const Text("Summary Type:"),
                Row(
                  children: [
                    Radio(
                      value: "Extractive",
                      groupValue: _audioSummaryType,
                      onChanged: (value) {
                        setState(() {
                          _audioSummaryType = value.toString();
                          _saveSettings();
                        });
                      },
                    ),
                    const Text("Extractive"),
                    const SizedBox(width: 20),
                    Radio(
                      value: "Abstractive",
                      groupValue: _audioSummaryType,
                      onChanged: (value) {
                        setState(() {
                          _audioSummaryType = value.toString();
                          _saveSettings();
                        });
                      },
                    ),
                    const Text("Abstractive"),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // **Other Summary Storage Options**
              CheckboxListTile(
                title: const Text("Store Text Summary"),
                value: _storeTextSummary,
                onChanged: (value) {
                  setState(() {
                    _storeTextSummary = value ?? false;
                    _saveSettings();
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Store Audio Summary"),
                value: _storeAudioSummary,
                onChanged: (value) {
                  setState(() {
                    _storeAudioSummary = value ?? false;
                    _saveSettings();
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Store Image Summary"),
                value: _storeImageSummary,
                onChanged: (value) {
                  setState(() {
                    _storeImageSummary = value ?? false;
                    _saveSettings();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
