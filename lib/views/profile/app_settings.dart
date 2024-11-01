import 'package:flutter/material.dart';
import 'package:inq_app/views/profile/personal_info_updates.dart';
import 'package:inq_app/views/profile/change_password.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  String _currentTheme = 'system'; // Options: 'light', 'dark', 'system'

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'light',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() {
                    _currentTheme = value!;
                  });
                  // Implement light theme
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'dark',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() {
                    _currentTheme = value!;
                  });
                  // Implement dark theme
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('System Default'),
                value: 'system',
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() {
                    _currentTheme = value!;
                  });
                  // Implement system default theme
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _testNotification() {
    // Implement test notification logic
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
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
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
            ListTile(
              title: const Text('User Account'),
              leading: const Icon(Icons.person_outline),
              subtitle: const Text('Update your name, email, and phone number'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileUpdateScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Password'),
              leading: const Icon(Icons.lock_outline),
              subtitle: const Text('Change your password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordScreen(),
                  ),
                );
              },
            ),
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
            // ListTile(
            //   title: const Text('Notification'),
            //   leading: const Icon(Icons.notifications_outlined),
            //   subtitle: const Text('Enable or disable notifications'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const NotificationSettings(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              title: const Text('Display'),
              leading: const Icon(Icons.brightness_6_outlined),
              subtitle: const Text('Change the theme of the app'),
              onTap: () {
                _showThemeDialog();
              },
            ),
            // ListTile(
            //   title: const Text('Test Notification'),
            //   leading: const Icon(Icons.notification_add_outlined),
            //   subtitle: const Text('Test the notification system'),
            //   onTap: () {
            //     _testNotification();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
