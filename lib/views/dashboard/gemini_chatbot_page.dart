import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:inq_app/models/chatbot.dart';
import 'package:intl/intl.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiChatbotPage extends StatefulWidget {
  const GeminiChatbotPage({Key? key}) : super(key: key);

  @override
  _GeminiChatbotPageState createState() => _GeminiChatbotPageState();
}

class _GeminiChatbotPageState extends State<GeminiChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  static const apiKey = "AIzaSyB2-UaQS-oLx1qV6HhN0IRA0sa9Z-VXDsk";
  late final GenerativeModel _model;
  late final FirestoreService _appointmentService;
  late final AppointmentProvider _appointmentProvider;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _appointmentService = FirestoreService();
    _appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    _loadMessages();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = jsonEncode(_messages.map((m) => m.toMap()).toList());
    await prefs.setString('chat_history', messagesJson);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_history');
    if (messagesJson != null) {
      final List<dynamic> decodedMessages = jsonDecode(messagesJson);
      setState(() {
        _messages = decodedMessages.map((m) => ChatMessage.fromMap(m)).toList();
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _messages.removeWhere((message) => message.id == messageId);
    });
    await _saveMessages();
  }

  Future<void> _clearAllMessages() async {
    setState(() {
      _messages.clear();
    });
    await _saveMessages();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Scroll to the bottom
    _scrollToBottom();

    try {
      final response = await _getContextualResponse(userMessage);

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Error: ${e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }

    // Scroll to the bottom again after receiving the response
    _scrollToBottom();

    await _saveMessages();
  }

  Future<String> _getContextualResponse(String userMessage) async {
    final lowercaseMessage = userMessage.toLowerCase();
    DateTime? date = _parseRelativeDate(lowercaseMessage);

    String? department = _extractDepartment(lowercaseMessage);
    String? service = _extractService(lowercaseMessage);

    // Wellness-related predefined responses
    if (lowercaseMessage.contains('mental health')) {
      return "Mental health is important! Make sure to practice mindfulness and seek support when needed. Our wellness center offers counseling services if you'd like to talk to someone.";
    }

    if (lowercaseMessage.contains('nutrition') ||
        lowercaseMessage.contains('diet')) {
      return "A balanced diet is key to good health! Our wellness center offers a food nutrition program to guide you in making healthier food choices.";
    }

    if (lowercaseMessage.contains('exercise') ||
        lowercaseMessage.contains('fitness')) {
      return "Regular exercise is great for both your physical and mental health. Consider joining one of our group wellness programs!";
    }
    // Use a regex or simple matching to handle relative dates like 'tomorrow', 'next week'

    if (department != null && service != null && date != null) {
      // Use the identified date, service, and department to check availability
      final availableSlots = await _appointmentService.getAvailableTimeSlots(
          department, service, DateFormat('yyyy-MM-dd').format(date));
      if (availableSlots.isNotEmpty) {
        return "Here are the available timeslots for $service in $department on ${DateFormat('yyyy-MM-dd').format(date)}:\n${availableSlots.join('\n')}";
      } else {
        return "No available slots for $service in $department on ${DateFormat('yyyy-MM-dd').format(date)}.";
      }
    }

    // Application-related queries (existing logic)
    if (lowercaseMessage.contains('available timeslots for $service') ||
        lowercaseMessage.contains('check availability')) {
      // Existing logic for checking availability
      String? department = _extractDepartment(lowercaseMessage);
      String? service = _extractService(lowercaseMessage);
      String? date = _extractDate(lowercaseMessage);

      if (department != null && service != null && date != null) {
        final availableSlots = await _appointmentService.getAvailableTimeSlots(
            department, service, date);
        if (availableSlots.isNotEmpty) {
          return "Great! Here are the available timeslots for $service in $department on $date:\n${availableSlots.join('\n')}";
        } else {
          return "I'm sorry, there are no available slots for $service in $department on $date. Would you like to check another date?";
        }
      } else if (department != null && service != null) {
        return "Sure, I can help you check availability for $service in $department. What date would you like to check? (Please specify in YYYY-MM-DD format)";
      } else if (department != null) {
        final services = _appointmentProvider.services[department] ?? [];
        return "For $department, we offer these services:\n${services.join('\n')}\nWhich service would you like to check availability for?";
      } else {
        final departments = _appointmentProvider.departments;
        return "I'd be happy to help you check availability. We have these departments:\n${departments.join('\n')}\nWhich department are you interested in?";
      }
    }

    // Appointment booking, management, etc.
    if (lowercaseMessage.contains('book appointment') ||
        lowercaseMessage.contains('schedule')) {
      return "To book an appointment, please use the 'Book Appointment' feature in the app. I can help you check available timeslots, but the actual booking should be done through the app interface for security reasons.";
    }

    // Default response
    return "I'm here to help with wellness advice and application-related services. You can ask me about mental health, nutrition, or check appointment availability. How can I assist you today?";
  }

  DateTime? _parseRelativeDate(String message) {
    if (message.contains('tomorrow')) {
      return DateTime.now().add(Duration(days: 1));
    } else if (message.contains('next week')) {
      return DateTime.now().add(Duration(days: 7));
    } else if (message.contains('weekend')) {
      // Assume Saturday as the weekend start
      return DateTime.now().add(Duration(days: 7));
    }
    return null;
  }

  String? _extractDepartment(String message) {
    for (String department in _appointmentProvider.departments) {
      if (message.contains(department.toLowerCase())) {
        return department;
      }
    }
    return null;
  }

  String? _extractService(String message) {
    for (var services in _appointmentProvider.services.values) {
      for (String service in services) {
        if (message.contains(service.toLowerCase())) {
          return service;
        }
      }
    }
    return null;
  }

  String? _extractDate(String message) {
    // Simple regex to match YYYY-MM-DD format
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final match = dateRegex.firstMatch(message);
    return match?.group(0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('inQ Chatbot'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear all messages?'),
                  content: Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Clear'),
                      onPressed: () {
                        _clearAllMessages();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteMessage(message.id);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.orange : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: message.isUser ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
