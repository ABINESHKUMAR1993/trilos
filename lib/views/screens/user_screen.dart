import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo/constants/constants.dart';
import 'package:trilo/views/screens/audio_call_screen.dart';
import 'package:trilo/views/screens/chat_screen.dart';
import 'package:trilo/views/screens/video_call_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _isLoading = false;
  List<UserModel> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFollowedUsers();
  }

  Future<void> _fetchFollowedUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';
      print("Auth Token: $authToken");

      final response = await http.get(
        Uri.parse('$baseUrl/get_followed_users'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') && responseBody['data'] is Map) {
          setState(() {
            _users =
                responseBody['data'].values
                    .map<UserModel>((userJson) => UserModel.fromJson(userJson))
                    .toList();
            print("Users fetched: ${_users.length}");
          });
        } else {
          setState(() {
            _error = 'No followed users found';
          });
          print("Error: No followed users found");
        }
      } else {
        setState(() {
          _error = 'Failed to load users (${response.statusCode})';
        });
        print("Error: Failed to load users (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
        });
      }
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFollowedUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'You haven\'t followed anyone yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFollowedUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) => UserCard(user: _users[index]),
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 10),
          _buildUserInfo(),
          const SizedBox(height: 10),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(user.profileImage),
          onBackgroundImageError: (_, __) {
            // Handle error loading image
            print("Error loading profile image: ${user.profileImage}");
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildOnlineStatus(),
                ],
              ),
              const SizedBox(height: 4),
              Text('${user.gender}, ${user.age}'),
              const SizedBox(height: 3),
              Text(user.location),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineStatus() {
    return Row(
      children: const [
        Icon(Icons.circle, color: Colors.green, size: 12),
        SizedBox(width: 4),
        Text('Online', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages: ${user.languages.join(", ")}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Interests: ${user.interests.join(", ")}',
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: Icons.call,
          onPressed: () {
            print("Audio call with: ${user.name ?? 'No Name'}");
            Get.to(
              () => AudioCallScreen(
                userName: user.name ?? 'No Name',
                profileImageUrl: user.profileImage,
              ),
            );
          },
        ),
        _buildIconButton(
          icon: Icons.chat,
          onPressed: () {
            print("Chat with: ${user.name ?? 'No Name'}");
            Get.to(
              () => ChatPage(
                profileImageUrl: user.profileImage,
                userName: user.name ?? 'No Name',
                receiverId: user.id.toString(),
              ),
            );
          },
        ),
        _buildIconButton(
          icon: Icons.video_call_outlined,
          onPressed: () {
            print("Video call with: ${user.name ?? 'No Name'}");
            Get.to(() => VideoCallScreen(userName: user.name ?? 'No Name'));
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink, width: 1.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.pink, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class UserModel {
  final int id;
  final String? name;
  final int age;
  final String gender;
  final String location;
  final List<String> interests;
  final List<String> languages;
  final String profileImage;

  const UserModel({
    required this.id,
    this.name,
    required this.age,
    required this.gender,
    required this.location,
    required this.interests,
    required this.languages,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      age: json['dob'] != null ? _calculateAge(DateTime.parse(json['dob'])) : 0,
      gender: json['gender'] ?? 'Unknown',
      location: json['country'] ?? 'Unknown',
      languages: _parseList(json['language']),
      interests: _parseList(json['interest']),
      profileImage: json['profile_image'] ?? 'assets/images/png/image.png',
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return ['Unknown'];
    if (value is List) return List<String>.from(value);
    return [value.toString()];
  }

  static int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}
