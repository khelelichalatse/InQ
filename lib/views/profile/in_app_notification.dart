// Screen for managing in-app notification preferences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  // State variables for notification settings
  bool _notificationsEnabled = true;  // Toggle for notifications
  Duration _reminderDuration = const Duration(hours: 24); // Default reminder time

  // Available reminder options
  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': '30 minutes before', 'duration': const Duration(minutes: 30)},
    {'label': '1 hour before', 'duration': const Duration(hours: 1)},
    {'label': '2 hours before', 'duration': const Duration(hours: 2)},
    {'label': '1 day before', 'duration': const Duration(hours: 24)},
  ];

  // Load saved settings from SharedPreferences
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _reminderDuration = Duration(
          minutes: prefs.getInt('reminderMinutes') ??
              1440); // 1440 minutes = 24 hours
    });
  }

  // Save current settings to SharedPreferences
  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('reminderMinutes', _reminderDuration.inMinutes);
  }

  // Helper method to get human-readable duration label
  String _getDurationLabel(Duration duration) {
    final option = _reminderOptions.firstWhere(
      (element) => element['duration'] == duration,
      orElse: () =>
          {'label': '1 day before', 'duration': const Duration(hours: 24)},
    );
    return option['label'] as String;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _saveSettings();
                });
              },
            ),
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(_getDurationLabel(_reminderDuration)),
              enabled: _notificationsEnabled,
              onTap: () {
                _showReminderTimePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Reminder Time'),
          children: _reminderOptions.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                _updateReminderTime(
                    option['duration'] as Duration, option['label'] as String);
                Navigator.pop(context);
              },
              child: Text(option['label'] as String),
            );
          }).toList(),
        );
      },
    );
  }

  void _updateReminderTime(Duration duration, String label) {
    setState(() {
      _reminderDuration = duration;
      _saveSettings();
    });
  }
}
