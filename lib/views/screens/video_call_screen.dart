import 'package:flutter/material.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final String userName; // Add the userName as a parameter.

  const VideoCallScreen({Key? key, required this.userName}) : super(key: key);

  @override
  VideoCallScreenState createState() => VideoCallScreenState();
}

class VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  int elapsedSeconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            bottom: 150,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(color: Colors.grey.shade800),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'mute',
                    onPressed: toggleMute,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.blue,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'end_call',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.red,
                    child: Icon(Icons.call_end, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'toggle_video',
                    onPressed: () {
                      // Implement video toggle logic if needed
                    },
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.videocam, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName, // Display userName
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTime(elapsedSeconds),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
