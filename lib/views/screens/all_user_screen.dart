import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo/constants/constants.dart';
import 'package:trilo/views/screens/audio_call_screen.dart';
import 'package:trilo/views/screens/chat_screen.dart';
import 'package:trilo/views/screens/profile_screen.dart';
import 'package:trilo/views/screens/video_call_screen.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({super.key});

  @override
  _AllUserScreenState createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  bool _isLoading = false;
  List<UserModel> _users = [];
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';
      final url = Uri.parse('$baseUrl/get_all_users');

      print('Requesting user data...');
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      print('Response received: ${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') &&
            responseBody['data'].containsKey('users')) {
          final List<dynamic> data = responseBody['data']['users'];
          setState(() {
            _users =
                data.map((userJson) => UserModel.fromJson(userJson)).toList();
          });
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = 'No users found in the response.';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Please login again to view users.';
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load users. Please try again later.';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error loading users. Please check your connection.';
        });
      }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(onRefresh: getAllUsers, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: getAllUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return UserCard(user: user);
      },
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  Future<UserModel?> fetchUserDetails(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';
      final url = Uri.parse('$baseUrl/get_user_details/$userId');

      print('Fetching details for user ID: $userId');
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      print('User details response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          return UserModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error occurred while fetching user details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );
          final userDetails = await fetchUserDetails(user.id);
          Get.back(); // Close the loading dialog
          Get.to(
            () => UserProfile(
              userId: user.id, // Passing user_id to UserProfile screen
              userName: userDetails?.name ?? user.name ?? 'No Name',
              user: userDetails ?? user,
            ),
          );
        } catch (e) {
          if (Get.isDialogOpen ?? false) Get.back();
          print('Failed to load user profile: $e');
          Get.snackbar(
            'Error',
            'Unable to load user profile',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    user.profileImageUrl.isNotEmpty
                        ? user.profileImageUrl
                        : 'https://example.com/default_profile.png',
                  ),
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
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color:
                                    user.isOnline ? Colors.green : Colors.red,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.isOnline ? 'Online' : 'Offline',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${user.gender}, ${user.age}'),
                      const SizedBox(height: 3),
                      Text(user.country),
                      const SizedBox(height: 3),
                      Text(user.languages.join(', ')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    'Expert on: ${user.interests.join(', ')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 15),
                _buildIconButton(
                  icon: Icons.call,
                  onPressed:
                      () => Get.to(
                        () => AudioCallScreen(
                          userName: user.name ?? 'No Name',
                          profileImageUrl: user.profileImageUrl,
                        ),
                      ),
                ),
                const SizedBox(width: 15),
                _buildIconButton(
                  icon: Icons.chat,
                  onPressed:
                      () => Get.to(
                        () => ChatPage(
                          profileImageUrl: user.profileImageUrl,
                          userName: user.name ?? 'No Name',
                          receiverId: user.id.toString(),
                        ),
                      ),
                ),
                const SizedBox(width: 15),
                _buildIconButton(
                  icon: Icons.video_call_outlined,
                  onPressed:
                      () => Get.to(
                        () => VideoCallScreen(userName: user.name ?? 'No Name'),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 38.0,
      height: 38.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink, width: 1.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.pink, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class UserModel {
  final int id;
  final String? name;
  final int? age;
  final String gender;
  final String country;
  final List<String> interests;
  final List<String> languages;
  final String profileImageUrl;
  final bool isOnline;
  final int? follower_count;
  final String about;
  final bool? isFollowing;

  UserModel({
    required this.id,
    this.name,
    this.age,
    required this.gender,
    required this.country,
    required this.interests,
    required this.languages,
    required this.profileImageUrl,
    required this.isOnline,
    required this.follower_count,
    required this.about,
    this.isFollowing,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String profileImageUrl = json['profile_image_url'] ?? '';
    if (profileImageUrl.isEmpty && json['profile_image'] != null) {
      profileImageUrl = json['profile_image'];
    }

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'] ?? '',
      country: json['country'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      profileImageUrl: profileImageUrl,
      isOnline: json['is_online'] ?? false,
      follower_count: json['follower_count'] ?? 0,
      about:
          json['data'] != null && json['data'].containsKey('about')
              ? json['data']['about']
              : '', // Check if 'data' exists and contains 'about'
      isFollowing: json['is_following'] ?? false,
    );
  }

  get isFollowed => null;
}
