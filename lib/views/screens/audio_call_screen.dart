import 'dart:async';
import 'package:flutter/material.dart';

class AudioCallScreen extends StatefulWidget {
  final String userName;
  final String profileImageUrl;

  const AudioCallScreen({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  AudioCallScreenState createState() => AudioCallScreenState();
}

class AudioCallScreenState extends State<AudioCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  int elapsedSeconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
  }

  Future<void> _endCall() async {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required String heroTag,
    double size = 56.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                          widget.profileImageUrl.isNotEmpty
                              ? widget.profileImageUrl
                              : 'https://example.com/default_profile.png',
                        ),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(elapsedSeconds),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      onPressed: _toggleMute,
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      backgroundColor:
                          isMuted
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white,
                      iconColor: isMuted ? Colors.white : Colors.blue,
                      heroTag: 'mute',
                    ),
                    _buildActionButton(
                      onPressed: _endCall,
                      icon: Icons.call_end,
                      backgroundColor: Colors.red,
                      iconColor: Colors.white,
                      heroTag: 'end_call',
                      size: 72.0,
                    ),
                    _buildActionButton(
                      onPressed: _toggleSpeaker,
                      icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      backgroundColor:
                          isSpeakerOn
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white,
                      iconColor: isSpeakerOn ? Colors.white : Colors.blue,
                      heroTag: 'speaker',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
