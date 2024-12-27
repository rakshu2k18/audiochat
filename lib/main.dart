import 'package:audiofeature/test.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AudioWaveformApp extends StatelessWidget {
  const AudioWaveformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const AudioWaveformScreen(),
    );
  }
}

class AudioWaveformScreen extends StatefulWidget {
  const AudioWaveformScreen({super.key});

  @override
  _AudioWaveformScreenState createState() => _AudioWaveformScreenState();
}

class _AudioWaveformScreenState extends State<AudioWaveformScreen> {
  final List<Map<String, String>> _audioList = [
    {
      'title': 'Audio 1',
      'url':
          'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3'
    },
    {
      'title': 'Online Audio',
      'url':
          'https://codeskulptor-demos.commondatastorage.googleapis.com/pang/paza-moduless.mp3'
    },
  ];

  int? _currentlyPlayingIndex;

  void _setCurrentlyPlayingIndex(int index) {
    setState(() {
      _currentlyPlayingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Waveforms"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestScreen()),
              );
            },
            child: const Icon(Icons.menu)),
      ),
      body: ListView.builder(
        itemCount: _audioList.length,
        itemBuilder: (context, index) {
          final audio = _audioList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                VoiceMessage(
                  url: audio['url']!,
                  isPlaying: _currentlyPlayingIndex == index,
                  onPlay: () => _setCurrentlyPlayingIndex(index),
                  index: index,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VoiceMessage extends StatefulWidget {
  final String url;
  final bool isPlaying;
  final VoidCallback onPlay;
  final int index;

  const VoiceMessage({
    Key? key,
    required this.url,
    required this.isPlaying,
    required this.onPlay,
    required this.index,
  }) : super(key: key);

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final AudioPlayer _player = AudioPlayer();
  final PlayerController _waveformController = PlayerController();
  late String _localPath;
  Color _fixedWaveColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _prepareAudio();
    _player.positionStream.listen((position) {
      double progress =
          position.inMilliseconds / _player.duration!.inMilliseconds;
      setState(() {
        _fixedWaveColor = progress >= 1.0 ? Colors.grey : Colors.blue;
      });
    });
  }

  Future<void> _prepareAudio() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final byteData = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        _localPath = "${tempDir.path}/${widget.url.split('/').last}";
        final tempFile = File(_localPath)..writeAsBytesSync(byteData);

        await _waveformController.preparePlayer(
          path: _localPath,
          shouldExtractWaveform: true,
          noOfSamples: 50,
        );

        await _player.setFilePath(_localPath);
      }
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _playAudio() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      AudioManager().stopCurrentAudio();
      await _player.play();
    }
    setState(() {});
    widget.onPlay(); 
    _waveformController.updateFrequency;
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _playAudio,
                child: Icon(
                  _player.playing ? Icons.pause : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) async {
                    final position = details.localPosition.dx /
                        MediaQuery.of(context).size.width *
                        _player.duration!.inMilliseconds;
                    await _player
                        .seek(Duration(milliseconds: position.toInt()));
                    setState(() {});
                  },
                  child: AudioFileWaveforms(
                    size: const Size(300, 50),
                    playerController: _waveformController,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: _fixedWaveColor,
                      liveWaveColor: Colors.grey,
                      waveThickness: 2,
                    ),
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
              ),
            ],
          ),
          Text(
            "1:20",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static final AudioPlayer _player = AudioPlayer();

  AudioManager._internal();

  factory AudioManager() => _instance;

  AudioPlayer get player => _player;

  void stopCurrentAudio() {
    if (_player.playing) {
      _player.pause();
    }
  }
}

void main() {
  runApp(const AudioWaveformApp());
}
