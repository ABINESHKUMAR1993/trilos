import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:trilo/views/screens/home_screen.dart';

class VoiceVerificationScreen extends StatefulWidget {
  const VoiceVerificationScreen({super.key});

  @override
  VoiceVerificationScreenState createState() => VoiceVerificationScreenState();
}

class VoiceVerificationScreenState extends State<VoiceVerificationScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceInput = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      _showErrorDialog('Speech recognition not available on this device.');
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _isProcessing = true;
      _voiceInput = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceInput = result.recognizedWords;
            if (result.finalResult) {
              _detectGender(_voiceInput);
            }
          });
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
        partialResults: false,
        onSoundLevelChange: (level) {
          print('Sound level: $level');
        },
      );
    } catch (e) {
      _showErrorDialog('Error starting voice recognition: $e');
      await _stopListening();
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _isProcessing = false;
    });
  }

  void _detectGender(String voice) {
    if (voice.isEmpty) {
      _showErrorDialog('No voice input detected. Please try again.');
      return;
    }

    // Convert to lowercase for case-insensitive matching
    final lowerVoice = voice.toLowerCase();

    // Add more sophisticated gender detection logic here
    if (lowerVoice.contains('he') ||
        lowerVoice.contains('his') ||
        lowerVoice.contains('male') ||
        lowerVoice.contains('man')) {
      setState(() {});
      _showSuccessMessage();
    } else if (lowerVoice.contains('she') ||
        lowerVoice.contains('her') ||
        lowerVoice.contains('female') ||
        lowerVoice.contains('woman')) {
      setState(() {});
      _showErrorDialog(
        'Female voice detected. Please verify with a male voice.',
      );
    } else {
      setState(() {});
      _showErrorDialog('Unable to determine voice gender. Please try again.');
    }
  }

  void _showSuccessMessage() {
    _stopListening();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Male voice verified successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.off(
                  () => HomeScreen(),
                ); // Use Get.off to prevent back navigation
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    _stopListening();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Voice Verification",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Male Voice Verification",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Friendship Turns Moments Into Memories.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(),
            if (_voiceInput.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Detected: $_voiceInput",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _isListening
                    ? "Listening... Speak the sentence above"
                    : "Click the microphone and read the sentence above",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: FloatingActionButton(
                onPressed: _toggleListening,
                backgroundColor: _isListening ? Colors.red : Colors.pink,
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
