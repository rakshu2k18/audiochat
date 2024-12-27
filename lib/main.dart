import 'package:audiofeature/voice.dart';
import 'package:flutter/material.dart';

class AudioWaveformApp extends StatelessWidget {
  const AudioWaveformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioWaveformScreen(),
    );
  }
}

class AudioWaveformScreen extends StatefulWidget {
  const AudioWaveformScreen({super.key});

  @override
  _AudioWaveformScreenState createState() => _AudioWaveformScreenState();
}

class _AudioWaveformScreenState extends State<AudioWaveformScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
child: VoiceMessage(
        // backgroundColor: Colors.white,
        // time: DateTime.now(),
        // status: MessageStatus.read,
        // currentUserIsSender: true,
        // doneColor: Colors.lightBlueAccent,
        url: 'https://codeskulptor-demos.commondatastorage.googleapis.com/pang/paza-moduless.mp3',
        // fixedWaveColor: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.2),
        // liveWaveColor: Theme.of(context).colorScheme.primary,
      ),
),);
  }
}

void main() {
  runApp(const AudioWaveformApp());
}
