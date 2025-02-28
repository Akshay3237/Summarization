import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

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

  @override
  void initState() {
    super.initState();
    initRenderers();
    setupSignaling();
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
  }

  Future<void> joinCall() async {
    if (roomIdController.text.isNotEmpty) {
      await signaling.openUserMedia(localRenderer, remoteRenderer);
      await signaling.joinRoom(roomIdController.text, remoteRenderer);
    }
  }

  Future<void> endCall() async {
    await signaling.hangUp(localRenderer);
    setState(() {
      isRoomCreated = false;
      roomId = null;
    });
  }

  void copyToClipboard() {
    if (roomId != null) {
      Clipboard.setData(ClipboardData(text: roomId!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room ID copied to clipboard!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Call")),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(localRenderer)),
          Expanded(child: RTCVideoView(remoteRenderer)),

          // Room ID Display & Copy Button
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

          // Room ID Input Field for Callee
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

          // Buttons
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
