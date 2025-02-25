import 'package:flutter/material.dart';
import 'package:textsummarize/pages/audio_summarize.dart';
import '../pages/text_summarizer.dart';
import '../pages/video_call.dart';
import '../pages/audio_call.dart';
import '../pages/storage.dart';
import '../pages/settings.dart';
import '../pages/about_us.dart';
import '../pages/profile.dart'; // Profile page for the additional button

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.text_fields,
            label: 'Text Summarize',
            destination: const TextSummarizerPage(),
          ),
          _buildDrawerItem(
            context,
            icon:Icons.mic,
            label: 'Audio Summarize',
            destination: AudioSummarize(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.video_call,
            label: 'Video Call',
            destination:  VideoCallPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.call,
            label: 'Audio Call',
            destination: const AudioCallPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.storage,
            label: 'Storage',
            destination: const StoragePage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            destination: const SettingsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            label: 'About Us',
            destination: const AboutUsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            destination: const ProfilePage(), // Add your Profile page
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String label, required Widget destination}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}