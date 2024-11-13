import 'package:flutter/material.dart';
import 'package:inq_app/views/profile/personal_info_updates.dart';
import 'package:inq_app/views/profile/change_password.dart';

// Widget for managing application settings and preferences
class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  // Track current theme selection - defaults to system
  String _currentTheme = 'system'; // Options: 'light', 'dark', 'system'

  // Display theme selection dialog with radio buttons
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Light theme option
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'light',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() => _currentTheme = value!);
                  Navigator.pop(context);
                  // TODO: Implement light theme
                },
              ),
              // Dark theme option
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'dark',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() => _currentTheme = value!);
                  Navigator.pop(context);
                  // TODO: Implement dark theme
                },
              ),
              // System default theme option
              RadioListTile<String>(
                title: const Text('System Default'),
                value: 'system',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() => _currentTheme = value!);
                  Navigator.pop(context);
                  // TODO: Implement system default theme
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Test notification functionality
  void _testNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.orange,
      ),
      // Main settings list
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            // Account section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // User account settings
            ListTile(
              title: const Text('User Account'),
              leading: const Icon(Icons.person_outline),
              subtitle: const Text('Update your name, email, and phone number'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileUpdateScreen(),
                ),
              ),
            ),
            // Password settings
            ListTile(
              title: const Text('Password'),
              leading: const Icon(Icons.lock_outline),
              subtitle: const Text('Change your password'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              ),
            ),
            // Preferences section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Display/Theme settings
            ListTile(
              title: const Text('Display'),
              leading: const Icon(Icons.brightness_6_outlined),
              subtitle: const Text('Change the theme of the app'),
              onTap: _showThemeDialog,
            ),
            // Note: Commented out notification settings for future implementation
          ],
        ),
      ),
    );
  }
}
