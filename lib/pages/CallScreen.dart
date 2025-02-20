import 'package:cloud_firestore/cloud_firestore.dart';
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
  RTCPeerConnection? _peerConnection;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool startContainer = false;
  bool showSmallCamera = true;
  bool isMicOn = true;
  bool isCameraOn = true;
  bool isRemoteMicOn = true;
  bool isRemoteCameraOn = true;
  double xPos = 20;
  double yPos = 50;

  @override
  void initState() {
    super.initState();
    initRenderers();
    startLocalStream();
    setupWebRTC();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> setupWebRTC() async {
    _peerConnection = await createPeerConnection({"iceServers": [{"urls": "stun:stun.l.google.com:19302"}]}, {});
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _firestore.collection("message").doc(widget.meetingId).set({
        'candidates': FieldValue.arrayUnion([candidate.toMap()]),
      }, SetOptions(merge: true));
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    listenForICECandidates();

    if (widget.isCaller) {
      createOffer();
    } else {
      listenForOffer();
    }
  }

  Future<void> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await _firestore.collection("message").doc(widget.meetingId).set({
      'offer': offer.toMap(),
    });
  }

  void listenForOffer() {
    _firestore.collection("message").doc(widget.meetingId).snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['offer'] != null) {
        RTCSessionDescription offer = RTCSessionDescription(
          snapshot.data()!['offer']['sdp'],
          snapshot.data()!['offer']['type'],
        );
        await _peerConnection!.setRemoteDescription(offer);
        createAnswer();
      }
    });
  }

  Future<void> createAnswer() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await _firestore.collection("message").doc(widget.meetingId).set({
      'answer': answer.toMap(),
    }, SetOptions(merge: true));
  }

  void listenForAnswer() {
    _firestore.collection("message").doc(widget.meetingId).snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['answer'] != null) {
        RTCSessionDescription answer = RTCSessionDescription(
          snapshot.data()!['answer']['sdp'],
          snapshot.data()!['answer']['type'],
        );
        await _peerConnection!.setRemoteDescription(answer);
      }
    });
  }

  void listenForICECandidates() {
    _firestore.collection("message").doc(widget.meetingId).snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['candidates'] != null) {
        List<dynamic> candidates = snapshot.data()?['candidates'];
        for (var candidate in candidates) {
          await _peerConnection!.addCandidate(RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          ));
        }
      }
    });
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
    await Future.delayed(Duration(milliseconds: 500));
    _localRenderer.srcObject = stream;

    setState(() {
      _localStream = stream;
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
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
