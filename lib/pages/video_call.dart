import 'package:flutter/material.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import 'package:textsummarize/models/Pair.dart';

import 'package:textsummarize/services/IServiceVideoCall.dart';
import '../services/IUserService.dart';
import 'CallScreen.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _callIdController = TextEditingController();
  final IUserService _userService = Injection.getInstance<IUserService>(IUserService.typeName, true);
  final IServiceVideoCall _callService = Injection.getInstance<IServiceVideoCall>(IServiceVideoCall.typeName, true);
  String _callStatus = "Idle"; // Status to show (Idle, Calling, Pending, etc.)
  String? _callId;

  void _startCall() async {
    String receiverEmail = _emailController.text.trim();
    // Find user by email
    Pair<bool, Object> response = await _userService.findByMail(receiverEmail);

    if (response.first == false) {
      setState(() {
        _callStatus = "Invalid Email"; // Set status to show invalid email
      });
      return; // Exit if the email is not found
    }

    if (receiverEmail.isNotEmpty) {
      setState(() {
        _callStatus = "Calling $receiverEmail...";
      });

      // Initiate the call and get the call ID
      _callId = await _callService.initiateCall(receiverEmail);

      // Navigate to CallScreen after initiating the call
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>CallScreen(meetingId: _callId!,),
        ),
      );
    }
  }

  void _joinCall() async {
    String enteredCallId = _callIdController.text.trim();
    if (enteredCallId.isNotEmpty) {
      _callId = enteredCallId;

      // Check if the call exists and if it is pending
      try {
        String status = await _callService.getCallStatus(enteredCallId);
        if (status == 'pending') {
          await _callService.joinCall(enteredCallId);
          setState(() {
            _callStatus = "Joined the call...";
          });
          // Navigate to CallScreen after joining
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(meetingId: enteredCallId),
            ),
          );
        } else if (status == 'rejected') {
          setState(() {
            _callStatus = "Call has been rejected.";
          });
        } else {
          setState(() {
            _callStatus = "Call is already accepted.";
          });
        }
      } catch (e) {
        setState(() {
          _callStatus = "Error: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Call")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Option to either create a call or join a call
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Enter recipient's email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startCall,
              child: Text("Start Call"),
            ),
            SizedBox(height: 20),
            Divider(),
            // OR Join a call section
            TextField(
              controller: _callIdController,
              decoration: InputDecoration(labelText: "Enter call ID to join"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinCall,
              child: Text("Join Call"),
            ),
            SizedBox(height: 20),
            Text(
              "Call Status: $_callStatus", // Show the current call status
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
