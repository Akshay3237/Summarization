import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../dependencies/signalingaudio.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({Key? key}) : super(key: key);

  @override
  _AudioCallPageState createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final SignalingForAudio signaling = SignalingForAudio();
  stt.SpeechToText speech = stt.SpeechToText();
  TextEditingController _roomIdController = TextEditingController();

  String _transcription = "";
  String? roomId;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  /// Initialize Speech-to-Text
  Future<void> _initSpeechToText() async {
    bool available = await speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );
    if (!available) {
      print("Speech-to-Text not available.");
    }
  }

  /// Start speech recognition
  void _startListening() async {
    await speech.listen(
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });
      },
    );
  }

  /// Create a call room and start listening
  Future<void> _createRoom() async {
    String createdRoomId = await signaling.createRoom();
    setState(() {
      roomId = createdRoomId;
      _roomIdController.text = createdRoomId; // Update TextField
      _transcription = "Listening..."; // Reset transcription
    });
    _startListening();
  }

  /// Join an existing room and start listening
  Future<void> _joinRoom() async {
    String enteredRoomId = _roomIdController.text.trim();
    if (enteredRoomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Room ID!")),
      );
      return;
    }
    await signaling.joinRoom(enteredRoomId);
    setState(() {
      roomId = enteredRoomId;
      _transcription = "Listening...";
    });
    _startListening();
  }

  /// End the call and reset UI
  Future<void> _hangUp() async {
    try {
      await signaling.hangUp();
      await speech.stop();
    } catch (e) {
      print("Error: $e");
    }
    setState(() {
      roomId = null;
      _transcription = "";
      _roomIdController.clear();
    });
  }

  /// Copy Room ID to Clipboard
  void _copyRoomId() {
    if (roomId != null) {
      Clipboard.setData(ClipboardData(text: roomId!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room ID copied: $roomId")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call with Speech-to-Text')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Room ID Input Field
            TextField(
              controller: _roomIdController,
              decoration: InputDecoration(
                labelText: "Enter Room ID",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyRoomId,
                  tooltip: "Copy Room ID",
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Transcription Display
            Expanded(
              child: Center(
                child: Text(
                  roomId != null ? "Transcription: $_transcription" : "",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createRoom,
                  child: const Text('Create Room'),
                ),
                ElevatedButton(
                  onPressed: _joinRoom,
                  child: const Text('Join Room'),
                ),
                ElevatedButton(
                  onPressed: _hangUp,
                  child: const Text('Hang Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
