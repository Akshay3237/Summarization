import 'package:flutter/material.dart';

class ErrorShow extends StatelessWidget {
  final String geterror;

  const ErrorShow({super.key, required this.geterror});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(), // Makes container take full screen
          color: Colors.red, // Background color
          child: Center(
            child: Text(
              geterror,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white, // Visible on red background
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
