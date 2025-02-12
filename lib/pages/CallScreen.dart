// call_screen.dart

import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String callId;

  CallScreen({required this.callId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Call - Call ID: $callId")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("In Call with callid $callId", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            // Add WebRTC video call UI here in the future
            ElevatedButton(
              onPressed: () {
                // Handle call end here
                Navigator.pop(context);
              },
              child: Text("End Call"),
            ),
          ],
        ),
      ),
    );
  }
}
