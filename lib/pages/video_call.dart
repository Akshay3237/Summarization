import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../dependencies/dependencies.dart';
import '../models/Pair.dart';
import '../services/ISettingService.dart';
import '../services/IStorageService.dart';
import '../services/ISummarizeService.dart';
import '../dependencies/signaling.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late Signaling signaling;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  String? roomId;
  bool isRoomCreated = false;
  TextEditingController roomIdController = TextEditingController();
  ISummarizeService summarizeService = Injection.getInstance<ISummarizeService>(
      ISummarizeService.typeName, true);
  IStorageService storageService=Injection.getInstance<IStorageService>(IStorageService.typeName, true);
  final ISettingService _settingService =  Injection.getInstance<ISettingService>(
      ISettingService.typeName, true);
  // Speech-to-Text variables
  late stt.SpeechToText speech;
  bool isListening = false;
  String transcriptList = "";
  List<String> list=[];
  @override
  void initState() {
    super.initState();
    initRenderers();
    setupSignaling();
    speech = stt.SpeechToText();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void setupSignaling() {
    signaling = Signaling();
    signaling.onAddRemoteStream = (MediaStream stream) {
      setState(() {
        remoteRenderer.srcObject = stream;
      });
    };
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    roomIdController.dispose();
    super.dispose();
  }

  Future<void> startCall() async {
    await signaling.openUserMedia(localRenderer, remoteRenderer);
    roomId = await signaling.createRoom(remoteRenderer);
    setState(() {
      isRoomCreated = true;
    });
    var settings = await _settingService.getSettings();
    if (settings != null) {
      if (await _settingService.isVideoCallSummaryEnabled()) {
        startListening();
      } else {
        // Show a snackbar message informing the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video Call Summary is disabled1. Enable it from settings."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Video Call Summary is disabled2. Enable it from settings."),
          duration: Duration(seconds: 3),
        ),
      );
    }

  }

  Future<void> joinCall() async {
    if (roomIdController.text.isNotEmpty) {
      await signaling.openUserMedia(localRenderer, remoteRenderer);
      await signaling.joinRoom(roomIdController.text, remoteRenderer);


      //check start listening based on setting
      var settings = await _settingService.getSettings();
      if (settings != null) {
        if (await _settingService.isVideoCallSummaryEnabled()) {
          startListening();
        } else {
          // Show a snackbar message informing the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Video Call Summary is disabled. Enable it from settings."),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video Call Summary is disabled. Enable it from settings."),
            duration: Duration(seconds: 3),
          ),
        );
      }

    }
  }

  Future<void> endCall() async {
    var settings = await _settingService.getSettings();
    if (settings != null) {
      if (await _settingService.isVideoCallSummaryEnabled()) {
        stopListening();
        String finalTranscript = list.join(" ");
        print("Final Transcription: $finalTranscript");
        if (roomId != null) {
          await saveTranscriptAndSummaryToFirestore(roomId!, finalTranscript);
        }
      }
    }



    await signaling.hangUp(localRenderer);
    setState(() {
      isRoomCreated = false;
      roomId = null;
    });
  }
  // Store Final Transcript in Firestore
  Future<void> saveTranscriptAndSummaryToFirestore(String roomId, String transcript) async {
    if(transcript.isNotEmpty){
      int length=await _settingService.getVideoSummaryLength();
      Pair<bool, List<String>> result =
      await summarizeService.getSummary(transcript,length, await _settingService.getVideoSummaryType());
        if(result.first) {
          storageService.storeSummaryGeneratedFromText(text: transcript,
              summary: result.second,
              fromWhich: "fromvideocall",
              length:length);
        }
        else{
          print("Error in summarize video call"+result.second.join(" "));
        }
    }


    print("Transcript saved to Firestore!");
  }
  void copyToClipboard() {
    if (roomId != null) {
      Clipboard.setData(ClipboardData(text: roomId!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room ID copied to clipboard!")),
      );
    }
  }

  void startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
        if(status == "notListening" && isListening) {
          if(transcriptList.isNotEmpty){
            list.add(transcriptList);
          }
          transcriptList="";
          startListening();
        }
      },
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            transcriptList=result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 10), // Extend listening duration
        pauseFor: Duration(seconds: 3), // Allow short pauses
        partialResults: true, // Enable continuous transcription
      );
    }
  }

  void stopListening() {
    speech.stop();
    setState(() {
      isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Call")),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(localRenderer)),
          Expanded(child: RTCVideoView(remoteRenderer)),

          if (roomId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Room ID: $roomId",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: copyToClipboard,
                    tooltip: "Copy Room ID",
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: roomIdController,
              decoration: InputDecoration(
                labelText: "Enter Room ID",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Display live transcription
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Live Transcription: ${list.join(" ")}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: startCall,
                child: Text("Start Call"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: joinCall,
                child: Text("Join Call"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: endCall,
                child: Text("End Call"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
