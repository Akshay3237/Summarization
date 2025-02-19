import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String meetingId;
  final bool isCaller;
  CallScreen({required this.meetingId, required this.isCaller});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  bool startContainer = false;
  bool showSmallCamera = true; // Toggle small camera visibility

  bool isMicOn = true;
  bool isCameraOn = true;

  bool isRemoteMicOn = true;
  bool isRemoteCameraOn = true;

  double xPos = 20; // Initial X position of small container
  double yPos = 50; // Initial Y position of small container

  @override
  void initState() {
    super.initState();
    initRenderers();
    startLocalStream();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> startLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth": '640',
          "minHeight": '480',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    await Future.delayed(Duration(milliseconds: 500)); // Allow WebRTC to initialize
    _localRenderer.srcObject = stream;
    _remoteRenderer.srcObject = stream; // Currently, remote shows local stream

    setState(() {
      _localStream = stream;
    });
  }

  void toggleMic() {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !track.enabled;
      });
      setState(() {
        isMicOn = !isMicOn;
      });
    }
  }

  void toggleCamera() {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = !track.enabled;
      });
      setState(() {
        isCameraOn = !isCameraOn;
      });
    }
  }

  void toggleRemoteMic() {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !track.enabled;
      });
      setState(() {
        isRemoteMicOn = !isRemoteMicOn;
      });
    }
  }

  void toggleRemoteCamera() {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = !track.enabled;
      });
      setState(() {
        isRemoteCameraOn = !isRemoteCameraOn;
      });
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = 120;
    double containerHeight = 160;

    return Scaffold(
      appBar: AppBar(title: Text("Video Call")),
      body: Center(
        child: startContainer
            ? Stack(
          children: [
            // Big Remote Container
            Positioned.fill(
              child: Stack(
                children: [
                  Container(
                    color: Colors.black,
                    child: isRemoteCameraOn
                        ? RTCVideoView(_remoteRenderer)
                        : Center(child: Icon(Icons.videocam_off, color: Colors.white, size: 50)),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(isRemoteMicOn ? Icons.mic : Icons.mic_off, color: Colors.white),
                          onPressed: toggleRemoteMic,
                        ),
                        IconButton(
                          icon: Icon(isRemoteCameraOn ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                          onPressed: toggleRemoteCamera,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Small Local Container (Movable)
            if (showSmallCamera)
              Positioned(
                left: xPos,
                top: yPos,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double newX = xPos + details.delta.dx;
                      double newY = yPos + details.delta.dy;

                      // Prevent going outside screen
                      if (newX >= 0 && newX + containerWidth <= screenWidth) {
                        xPos = newX;
                      }
                      if (newY >= 0 && newY + containerHeight <= screenHeight) {
                        yPos = newY;
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: containerWidth,
                        height: containerHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: isCameraOn
                            ? RTCVideoView(_localRenderer)
                            : Center(child: Icon(Icons.videocam_off, color: Colors.white, size: 40)),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(isMicOn ? Icons.mic : Icons.mic_off, color: Colors.white, size: 20),
                              onPressed: toggleMic,
                            ),
                            IconButton(
                              icon: Icon(isCameraOn ? Icons.videocam : Icons.videocam_off,
                                  color: Colors.white, size: 20),
                              onPressed: toggleCamera,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(
              widget.meetingId,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  startContainer = true;
                });
              },
              child: Text("Start Call"),
            ),
          ],
        ),
      ),

      // Floating Buttons (Toggle Small Camera, End Call)
      floatingActionButton: startContainer
          ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                showSmallCamera = !showSmallCamera;
              });
            },
            child: Icon(
              showSmallCamera ? Icons.videocam_off : Icons.videocam,
              color: Colors.white,
            ),
            backgroundColor: showSmallCamera ? Colors.red : Colors.green,
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                startContainer = false;
              });
            },
            child: Icon(Icons.call_end, color: Colors.white),
            backgroundColor: Colors.red,
          ),
        ],
      )
          : null,
    );
  }
}
