import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class SignalingForAudio {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;

  Future<String> createRoom() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    print('Create PeerConnection with configuration: $configuration');
    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    var callerCandidatesCollection = roomRef.collection('callerCandidates');
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
    await roomRef.set(roomWithOffer);
    roomId = roomRef.id;
    print('New room created. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    peerConnection?.onTrack = (RTCTrackEvent event) {
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
    };

    roomRef.snapshots().listen((snapshot) async {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (peerConnection?.getRemoteDescription() == null && data['answer'] != null) {
          var answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
          await peerConnection?.setRemoteDescription(answer);
        }
      }
    });

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
        }
      });
    });

    return roomId!;
  }

  Future<void> joinRoom(String roomId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      peerConnection = await createPeerConnection(configuration);
      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate != null) {
          calleeCandidatesCollection.add(candidate.toMap());
        }
      };

      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
      var answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      await roomRef.update({'answer': {'type': answer.type, 'sdp': answer.sdp}});

      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
        });
      });
    }
  }

  Future<void> openUserMedia() async {
    var stream = await navigator.mediaDevices.getUserMedia({'audio': true});
    localStream = stream;
    remoteStream = await createLocalMediaStream('remote_audio');
  }

  Future<void> hangUp() async {
    localStream?.getTracks().forEach((track) => track.stop());
    remoteStream?.getTracks().forEach((track) => track.stop());
    peerConnection?.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      await roomRef.collection('calleeCandidates').get().then((snapshot) {
        snapshot.docs.forEach((document) => document.reference.delete());
      });
      await roomRef.collection('callerCandidates').get().then((snapshot) {
        snapshot.docs.forEach((document) => document.reference.delete());
      });
      await roomRef.delete();
    }

    localStream?.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
