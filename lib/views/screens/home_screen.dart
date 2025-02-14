import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trilo/constants/constants.dart';
import 'dart:convert';
import 'package:trilo/views/screens/drawer_screen.dart';
import 'package:trilo/views/screens/all_user_screen.dart';
import 'package:trilo/views/screens/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _screens = [const AllUserScreen(), FollowingScreen()];

  String talktimeAmount = "0";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserTalktimeAmount();
  }

  Future<void> _getUserTalktimeAmount() async {
    final url = Uri.parse('$baseUrl/get_usertalktime_amount');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            talktimeAmount = data['data']['talktime_amount'].toString();
          });
        }
      } else {
        throw Exception('Failed to load talktime amount');
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomeScreen with selectedTabIndex: $_selectedTabIndex");

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : TalkTimeWidget(talktimeAmount: talktimeAmount),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _TabButton(
                    label: 'All',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                        debugPrint("Tab changed to All");
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'Following',
                    isSelected: _selectedTabIndex == 1,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                        debugPrint("Tab changed to Following");
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: _screens[_selectedTabIndex]),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.pink),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.pink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class TalkTimeWidget extends StatelessWidget {
  final String talktimeAmount;

  const TalkTimeWidget({super.key, required this.talktimeAmount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.wallet, size: 20, color: Colors.pink),
        const SizedBox(width: 4),
        Text(
          '₹$talktimeAmount',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
