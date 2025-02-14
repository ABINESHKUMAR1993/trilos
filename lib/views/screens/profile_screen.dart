import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trilo/constants/constants.dart';
import 'package:trilo/constants/main_colors.dart';
import 'package:trilo/views/screens/all_user_screen.dart';
import 'package:trilo/views/screens/audio_call_screen.dart';
import 'package:trilo/views/screens/chat_screen.dart';
import 'package:trilo/views/screens/video_call_screen.dart';

class UserProfile extends StatefulWidget {
  final int userId;
  final String userName;
  final UserModel user;

  const UserProfile({
    super.key,
    required this.userId,
    required this.userName,
    required this.user,
  });

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  bool _isLoading = false;
  bool _isFollowed = false;
  int _followerCount = 0;

  @override
  void initState() {
    super.initState();
    _followerCount = widget.user.follower_count ?? 0;
    _isFollowed = widget.user.isFollowed ?? false;
  }

  Future<void> _userFollow() async {
    final url = Uri.parse('$baseUrl/user_follow');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFollowed = true;
          _followerCount++;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to follow user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error following user: $e');
    }
  }

  Future<void> _userUnfollow() async {
    final url = Uri.parse('$baseUrl/user_unfollow');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFollowed = false;
          _followerCount--;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to unfollow user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error unfollowing user: $e');
    }
  }

  Widget _buildProfileImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cPrimaryColor, width: 3),
      ),
      child: ClipOval(
        child: Image.network(
          widget.user.profileImageUrl.isNotEmpty
              ? widget.user.profileImageUrl
              : 'assets/images/default-profile.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              log('Navigating to chat with user: ${widget.user.id}');
              Get.to(
                () => ChatPage(
                  profileImageUrl: widget.user.profileImageUrl,
                  userName: widget.user.name ?? 'No Name',
                  receiverId: widget.user.id.toString(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: cPrimaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Say Hi',
              style: TextStyle(color: cPrimaryColor, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              log('Navigating to audio call with user: ${widget.user.id}');
              Get.to(
                () => AudioCallScreen(
                  userName: widget.user.name ?? 'No Name',
                  profileImageUrl: widget.user.profileImageUrl,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Audio Call',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              log('Navigating to video call with user: ${widget.user.id}');
              Get.to(
                () => VideoCallScreen(userName: widget.user.name ?? 'No Name'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Video Call',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileImage(),
                      const SizedBox(width: 50),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.user.gender}, ${widget.user.age}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Followers: $_followerCount',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.country,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFollowed ? _userUnfollow : _userFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                _isFollowed ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('Interests', widget.user.interests),
            const SizedBox(height: 24),
            _buildSection('Languages', widget.user.languages),
            const SizedBox(height: 24),
            _buildSection('About', [widget.user.about]),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          items.isEmpty ? 'No $title Available' : items.join(', '),
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }
}
