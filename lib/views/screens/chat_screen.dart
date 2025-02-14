import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo/constants/constants.dart'; // Make sure this file has baseUrl and apiKey
import 'package:trilo/constants/main_colors.dart'; // Ensure cPrimaryColor is defined
import 'package:trilo/views/screens/audio_call_screen.dart';
import 'package:trilo/views/screens/video_call_screen.dart';

class ChatPage extends StatefulWidget {
  final String profileImageUrl;
  final String userName;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.profileImageUrl,
    required this.userName,
    required this.receiverId,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  bool isOnline = true; // For now, hardcoded; update it dynamically if needed.

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final url = Uri.parse('$baseUrl/get_messages');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      final body = json.encode({'receiver_id': widget.receiverId});

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey, // Ensure apiKey is defined in constants
          "Authorization": "Bearer $authToken",
        },
        body: body,
      );

      log("Response status code: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          final List<dynamic> messageData = responseBody['data'];
          setState(() {
            _messages.clear();
            _messages.addAll(
              messageData.map(
                (data) => Message(
                  text: data['message'],
                  time: _formatTimestamp(data['created_at']),
                  isSent: data['sender_id'] == authToken,
                ),
              ),
            );
          });
          log("Messages fetched successfully.");
        } else {
          throw Exception(
            'Failed to load messages: ${responseBody['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load messages. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      log("Error while fetching messages: $e");
      Get.snackbar(
        'Error',
        'Failed to load messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final messageText = _messageController.text;
    final url = Uri.parse('$baseUrl/send_message');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    final newMessage = Message(
      text: messageText,
      time: _getCurrentTime(),
      isSent: true,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final body = json.encode({
        'message': messageText,
        'receiver_id': widget.receiverId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      log("Request body: $body");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: body,
      );

      log("Response status code: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode != 200) {
        setState(() {
          _messages.remove(newMessage);
        });
        throw Exception('Failed to send message');
      }

      log("Message sent successfully.");
    } catch (e) {
      log("Error while sending message: $e");
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        _messages.remove(newMessage);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('h:mm a');
    return formatter.format(now);
  }

  static String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    final formatter = DateFormat('h:mm a');
    return formatter.format(date);
  }

  Widget _buildReceivedMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSentMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.done_all, size: 16, color: Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Your message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: cPrimaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: cPrimaryColor),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: cPrimaryColor),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.profileImageUrl),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: cPrimaryColor),
            onPressed: () {
              Get.to(() => VideoCallScreen(userName: widget.userName));
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: cPrimaryColor),
            onPressed: () {
              Get.to(
                () => AudioCallScreen(
                  userName: widget.userName,
                  profileImageUrl: widget.profileImageUrl,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Today',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        if (message.isSent) {
                          return _buildSentMessage(message.text, message.time);
                        } else {
                          return _buildReceivedMessage(
                            message.text,
                            message.time,
                          );
                        }
                      },
                    ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final String time;
  final bool isSent;

  Message({required this.text, required this.time, required this.isSent});
}
