import 'package:flutter/material.dart';
import 'package:textsummarize/pages/home.dart';
import './pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Summarizer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const LoginPage(), // Set LoginPage as the home
      home: const HomePage(), // Set LoginPage as the home

    );
  }
}
