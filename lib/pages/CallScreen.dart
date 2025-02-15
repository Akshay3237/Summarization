// call_screen.dart

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("This is video call screen");
  }

}
