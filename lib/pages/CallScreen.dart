// call_screen.dart

import 'package:flutter/material.dart';

// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

class CallScreen extends StatefulWidget {
  final String meetingId;

  CallScreen({required this.meetingId});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late MediaStream _localStream;
  List<MediaStream> _remoteStreams = [];
  late RTCVideoRenderer _localRenderer;
  List<RTCVideoRenderer> _remoteRenderers = [];
  bool isLocalRendererInitialized = false;

  bool isMicrophoneEnabled = true;
  bool isCameraEnabled = true;

  // Firebase subscriptions
  StreamSubscription? _iceCandidatesSubscription;
  StreamSubscription? _remoteStreamsSubscription;

  late RTCPeerConnection _peerConnection;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderers = [];
    _initializeMeeting();
  }

  @override
  void dispose() {
    _removeFirebaseListeners();
    _disposeStreams();
    _localRenderer.dispose();
    _remoteRenderers.forEach((renderer) => renderer.dispose());
    super.dispose();
  }

  void _initializeMeeting() async {
    try {
      // Initialize the local stream
      _localStream = await _getLocalStream();

      // Initialize the local renderer
      await _localRenderer.initialize();
      setState(() {
        _localRenderer.srcObject = _localStream;
        isLocalRendererInitialized = true;
      });

      // Set up remote stream handling logic
      _setupRemoteStreamHandlers();

      // Connect to the meeting
      await _connectToMeeting(widget.meetingId);
    } catch (e) {
      debugPrint("Error initializing meeting: $e");
      _showErrorSnackBar("Failed to start the meeting. Please try again.");
    }
  }

  Future<MediaStream> _getLocalStream() async {
    try {
      // Get the user's media stream (audio and video)
      MediaStream stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      return stream;
    } catch (e) {
      debugPrint("Error getting local stream: $e");
      _showErrorSnackBar("Failed to access microphone or camera.");
      rethrow;
    }
  }

  Future<void> _connectToMeeting(String meetingId) async {
    try {
      final config = {
        'iceServers': [
          {
            'urls': 'stun:stun.l.google.com:19302',
          },
        ],
      };

      _peerConnection = await createPeerConnection(config);

      // Add local stream to the peer connection
      _localStream.getTracks().forEach((track) {
        _peerConnection.addTrack(track, _localStream);
      });

      // Listen for remote tracks
      _peerConnection.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _onRemoteStreamAdded(event.streams[0]);
        }
      };

      // Listen for ICE candidates and send them to Firebase
      // _peerConnection.onIceCandidate = (RTCIceCandidate candidate) async {
      //   if (candidate != null) {
      //     await FirebaseDatabase.instance
      //         .ref("meetings/$meetingId/iceCandidates")
      //         .push()
      //         .set(candidate.toMap());
      //   }
      // };

      // _iceCandidatesSubscription = FirebaseDatabase.instance
      //     .ref("meetings/$meetingId/iceCandidates")
      //     .onChildAdded
      //     .listen((event) async {
      //   final data = event.snapshot.value as Map<dynamic, dynamic>;
      //   final candidate = RTCIceCandidate(
      //     data['candidate'],
      //     data['sdpMid'],
      //     data['sdpMLineIndex'],
      //   );
      //   await _peerConnection.addCandidate(candidate);
      // });

      // final meetingRef = FirebaseDatabase.instance.ref("meetings/$meetingId");
      // final snapshot = await meetingRef.child('offer').once();
      // if (snapshot.snapshot.value == null) {
      //   RTCSessionDescription offer = await _peerConnection.createOffer();
      //   await _peerConnection.setLocalDescription(offer);
      //   await meetingRef.child('offer').set(offer.toMap());
      // } else {
      //   final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      //   RTCSessionDescription offer = RTCSessionDescription(
      //     data['sdp'],
      //     data['type'],
      //   );
      //   await _peerConnection.setRemoteDescription(offer);
      //
      //   RTCSessionDescription answer = await _peerConnection.createAnswer();
      //   await _peerConnection.setLocalDescription(answer);
      //   await meetingRef.child('answer').set(answer.toMap());
      // }

      // meetingRef.child('answer').onValue.listen((event) async {
      //   if (event.snapshot.value != null) {
      //     final data = event.snapshot.value as Map<dynamic, dynamic>;
      //     RTCSessionDescription answer = RTCSessionDescription(
      //       data['sdp'],
      //       data['type'],
      //     );
      //     await _peerConnection.setRemoteDescription(answer);
      //   }
      // });
    } catch (e) {
      debugPrint("Error connecting to meeting: $e");
      _showErrorSnackBar("Failed to connect to the meeting.");
    }
  }

  void _setupRemoteStreamHandlers() {
    // _remoteStreamsSubscription = FirebaseDatabase.instance
    //     .ref("meetings/${widget.meetingId}/remoteStreams")
    //     .onChildAdded
    //     .listen((event) async {
    //   final streamId = event.snapshot.key;
    //   if (streamId != null) {
    //     MediaStream remoteStream = await _getRemoteStream(streamId);
    //     _onRemoteStreamAdded(remoteStream);
    //   }
    // });
  }

  Future<MediaStream> _getRemoteStream(String streamId) async {
    // Simulated remote stream for demo purposes
    MediaStream remoteStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    return remoteStream;
  }

  void _onRemoteStreamAdded(MediaStream stream) {
    RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
    remoteRenderer.initialize().then((_) {
      remoteRenderer.srcObject = stream;
      setState(() {
        _remoteStreams.add(stream);
        _remoteRenderers.add(remoteRenderer);
      });
    });
  }

  void _disposeStreams() {
    _localStream.dispose();
    for (var stream in _remoteStreams) {
      stream.dispose();
    }
  }

  void _removeFirebaseListeners() {
    _iceCandidatesSubscription?.cancel();
    _remoteStreamsSubscription?.cancel();
  }

  void _leaveMeeting() {
    _removeFirebaseListeners();
    _disposeStreams();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Meeting'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _leaveMeeting,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLocalStream(),
            SizedBox(height: 10),
            _buildRemoteStreams(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
                    color: isMicrophoneEnabled ? Colors.green : Colors.red,
                  ),
                  onPressed: _toggleMicrophone,
                ),
                IconButton(
                  icon: Icon(
                    isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                    color: isCameraEnabled ? Colors.green : Colors.red,
                  ),
                  onPressed: _toggleCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalStream() {
    if (!isLocalRendererInitialized) {
      return CircularProgressIndicator();
    }
    return Container(
      width: 200,
      height: 200,
      child: RTCVideoView(
        _localRenderer,
        mirror: true,
      ),
    );
  }

  Widget _buildRemoteStreams() {
    return Column(
      children: _remoteRenderers.map((renderer) {
        return Container(
          width: 200,
          height: 200,
          child: RTCVideoView(renderer),
        );
      }).toList(),
    );
  }

  void _toggleMicrophone() {
    setState(() {
      isMicrophoneEnabled = !isMicrophoneEnabled;
      _localStream.getAudioTracks().forEach((track) {
        track.enabled = isMicrophoneEnabled;
      });
    });
  }

  void _toggleCamera() {
    setState(() {
      isCameraEnabled = !isCameraEnabled;
      _localStream.getVideoTracks().forEach((track) {
        track.enabled = isCameraEnabled;
      });
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
