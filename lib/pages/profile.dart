import 'package:flutter/material.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';

import 'login.dart'; // Assuming you have a LoginPage for navigation

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Method to handle logout
  void _logout(BuildContext context) async {
    // Injecting the singleton instance of authService
   Iauthenticateservice authService =Injection.getInstance<Iauthenticateservice>(Iauthenticateservice.typeName, true);

    // Perform logout
    var logoutResult = await authService.logout();

    // If logout is successful, navigate back to login page
    if (logoutResult.first) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
      // Redirect to the login page after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      // If logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout Error: ${logoutResult.second.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _logout(context), // Handle logout when pressed
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
