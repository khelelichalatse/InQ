import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inq_app/services/firebase_storage_service.dart';
import 'package:inq_app/views/profile/about_us.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/views/Authentication/login_signup.dart';
import 'package:inq_app/views/profile/app_settings.dart';
import 'package:inq_app/views/profile/feedback_support.dart';
import 'package:inq_app/views/profile/contact_us.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  File? _image; // To hold the selected image file
  bool notificationStatus = true;
  FirebaseStorageService storageService = FirebaseStorageService();
  Map<String, dynamic>? userData; // To store user data from Firestore

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  // Fetch user data from AuthService (from Firestore)
  Future<void> _fetchUserData() async {
    final data = await _authService.fetchUserData();
    setState(() {
      userData = data;
    });
  }

  // Pick image from gallery and update profile photo
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Update profile photo in Firebase using AuthService
      await _authService.updateProfilePhoto(_image!);
      _fetchUserData(); // Refresh user data to reflect the updated profile photo
    } else {
      print("No image picked");
    }
  }

  // Show confirmation dialog for logout
  void showConfirmLogout() {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.6),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey)),
              onPressed: () async {
                try {
                  await _authService.signOut();
                  Navigator.of(context).pop(); // Close the dialog
                  _showLoadingDialog();

                  // Simulate logout delay
                  await Future.delayed(const Duration(seconds: 2));

                  if (!mounted) return;

                  // Close loading dialog and navigate to login screen
                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreenHome()),
                  );
                } catch (e) {
                  print('Error logging out: $e');
                }
              },
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Loading screen while logging out
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Logging out...'),
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Colors.orange,
                strokeWidth: 5,
              ),
              SizedBox(width: 20),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      // Show the user's profile image or a default placeholder if the image is not available
                      userData?['imageUrl'] != null || _image != null
                          ? CircleAvatar(
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : NetworkImage(userData!['imageUrl']!)
                                      as ImageProvider,
                              radius: 70,
                            )
                          : InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                radius: 70,
                                child: Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                      // Button to allow user to upload a new profile image
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 75,
                        child: Container(
                          height: 45,
                          width: 40,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData?['Name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(userData?['Email'] ?? 'No email available'),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onTertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            const SizedBox(height: 10),
                            ListTile(
                              leading: const Icon(Icons.settings_outlined),
                              title: const Text('App Settings'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AppSettings(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.feedback_outlined),
                              title: const Text('Feedback & Support'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FeedbackSupport(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.call_outlined),
                              title: const Text('Contact Us'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ContactUs(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.people_alt_outlined),
                              title: const Text('About Developers'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AboutUsScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Logout'),
                              onTap: showConfirmLogout,
                            ),
                            const SizedBox(height: 20),
                            const Center(child: Text("Powered By")),
                            Image.asset(
                              'assets/M4NSoftwares.png',
                              height: 70,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
