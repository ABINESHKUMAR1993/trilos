import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo/constants/constants.dart';

class MyLanguageScreen extends StatefulWidget {
  const MyLanguageScreen({super.key});

  @override
  State<MyLanguageScreen> createState() => _MyLanguageScreenState();
}

class _MyLanguageScreenState extends State<MyLanguageScreen> {
  List<LanguageOption> languages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    getLanguages();
  }

  Future<void> getLanguages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final url = Uri.parse('$baseUrl/my_languages');
    final prefs = await SharedPreferences.getInstance();
    final authToken =
        prefs.getString('auth_token') ?? ''; // Fallback to empty string if null

    try {
      debugPrint('Fetching languages from: $url'); // Debug log for the URL
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken", // Ensure the token is not null
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        final message = data['message'];

        // Handle success response
        if (status == 'success') {
          final languageData = data['data']['languages'] as List;

          setState(() {
            if (languageData.isEmpty) {
              _errorMessage = 'No languages available for this user.';
            } else {
              languages =
                  languageData.map((item) {
                    final languageNames = item['language_name'].split(
                      ',',
                    ); // Split comma-separated languages
                    return LanguageOption(
                      name: languageNames.join(
                        ', ',
                      ), // Join multiple languages with commas
                      imagePath: '', // Assuming no image path for now
                      isSelected: false,
                    );
                  }).toList();
              _successMessage = message;
            }
          });
        } else {
          setState(() {
            _errorMessage =
                message.isNotEmpty
                    ? message
                    : 'Failed to load languages. Please try again later.';
          });
        }
      } else {
        // Handle HTTP failure
        debugPrint(
          'Failed to load languages. Status Code: ${response.statusCode}',
        );
        setState(() {
          _errorMessage = 'Failed to load languages. Please try again later.';
        });
      }
    } catch (e) {
      debugPrint(
        'Error while fetching languages: $e',
      ); // Debug log for the error
      setState(() {
        _errorMessage =
            'An error occurred. Please check your internet connection or try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.pink,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My languages',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Show all your languages proudly to get better matches',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              // Loading, success, or error message
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 16),
              // Languages list
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return LanguageCard(
                      language: languages[index],
                      onTap: () {
                        setState(() {
                          languages[index].isSelected =
                              !languages[index].isSelected;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String imagePath;
  bool isSelected;

  LanguageOption({
    required this.name,
    required this.isSelected,
    required this.imagePath,
  });
}

class LanguageCard extends StatelessWidget {
  final LanguageOption language;
  final VoidCallback onTap;

  const LanguageCard({super.key, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                language.isSelected
                    ? const Color(0xFFE91E63)
                    : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a loading indicator and error handling for the image
            Image.network(
              language.imagePath,
              width: 40,
              height: 40,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // If the image is loaded, display it
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              language.name,
              style: TextStyle(
                fontSize: 14,
                color:
                    language.isSelected
                        ? const Color(0xFFE91E63)
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
