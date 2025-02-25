import 'package:flutter/material.dart';
import 'package:textsummarize/pages/audio_summarize.dart';
import '../widgets/build_button.dart';
import '../widgets/drawer_widget.dart';
import '../pages/text_summarizer.dart';
import '../pages/video_call.dart';
import '../pages/audio_call.dart';
import '../pages/storage.dart';
import '../pages/settings.dart';
import '../pages/about_us.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Summarizer'),
        centerTitle: true,
      ),
      drawer: const DrawerWidget(), // Add the reusable drawer widget here
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: isWide ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                BuildButton(
                  icon: Icons.text_fields,
                  label: 'Text Summarize',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TextSummarizerPage(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.mic,
                  label: 'Audio Summarize',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioSummarize(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.video_call,
                  label: 'Video Call',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallPage(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.call,
                  label: 'Audio Call',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AudioCallPage(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.storage,
                  label: 'Storage',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoragePage(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                BuildButton(
                  icon: Icons.info,
                  label: 'About Us',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
