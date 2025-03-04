import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';
import 'package:textsummarize/services/IUserService.dart';
import 'package:textsummarize/models/User.dart' as u;


import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  late IUserService _userService;
  late Iauthenticateservice _authService;
  String _fullName = 'Unknown';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _authService = Injection.getInstance<Iauthenticateservice>(
        Iauthenticateservice.typeName, true);
    _userService =
        Injection.getInstance<IUserService>(IUserService.typeName, true);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    var currentUser = FirebaseAuth.instance.currentUser; // Get the current user
    if (currentUser != null) {
      var userResult = await _userService.findById(currentUser.uid); // Fetch user by UID
      if (userResult.first) {
        var userData = userResult.second as u.User;
        setState(() {
          _fullName = userData.fullname ?? 'Unknown';
          _email = userData.email ?? '';
          _nameController.text = _fullName;
          _emailController.text = _email;
        });
      }
    }
  }


  Future<void> _updateProfile() async {
    var updatedUser = u.User(
      fullname: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    var result = await _userService.Update(updatedUser);
    if (result.first) {
      setState(() {
        _fullName = _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Unknown';
        _email = _emailController.text.trim();
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update Error: ${result.second.toString()}")),
      );
    }
  }

  void _logout(BuildContext context) async {
    var logoutResult = await _authService.logout();
    if (logoutResult.first) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
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
        actions: [
          _isEditing
              ? IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          )
              : IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isEditing
                ? TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            )
                : Text(
              'Full Name: $_fullName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isEditing
                ? TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            )
                : Text(
              'Email: $_email',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
