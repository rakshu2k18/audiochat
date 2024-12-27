import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VoiceMessage extends StatefulWidget {
  final String url;

  const VoiceMessage({Key? key, required this.url}) : super(key: key);

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
    double progress = position.inMilliseconds / _player.duration!.inMilliseconds;
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
      await _player.play();
    }
    setState(() {});
     _waveformController.updateFrequency;
  }

  @override
  void dispose() {
    _player.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Container(
    height: 100,
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    padding: EdgeInsets.all(10),
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
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTapDown: (details) async {
                    final position = details.localPosition.dx /
                        MediaQuery.of(context).size.width *
                        _player.duration!.inMilliseconds;
                    await _player.seek(Duration(milliseconds: position.toInt()));
                    setState(() {});
                  },
                child: AudioFileWaveforms(
                  size: Size(300, 50),
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