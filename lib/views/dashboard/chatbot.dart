import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSatisfied = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _controller.clear();

    final response = await _getResponse(userMessage);

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
      _isLoading = false;
    });

    _askIfSatisfied();
  }

  Future<String> _getResponse(String message) async {
    // Pre-programmed responses
    if (message.toLowerCase().contains('book appointment')) {
      return "To book an appointment, please specify the department and service you're interested in. For example, 'I want to book an appointment for Health Aspect, Doctor's Appointment'.";
    } else if (message.toLowerCase().contains('cancel appointment')) {
      return "To cancel an appointment, please go to your profile, select 'My Appointments', and click 'Cancel' next to the appointment.";
    } else if (message.toLowerCase().contains('available dates')) {
      // Extract department and service from the message
      String department = _extractDepartment(message);
      String service = _extractService(message);
      if (department.isNotEmpty && service.isNotEmpty) {
        List<String> availableDates = await getAvailableDates(department, service);
        if (availableDates.isNotEmpty) {
          return "Available dates for $department, $service are: ${availableDates.join(', ')}";
        } else {
          return "Sorry, there are no available dates for $department, $service at the moment.";
        }
      } else {
        return "Please specify the department and service to check available dates. For example, 'What are the available dates for Health Aspect, Doctor's Appointment?'";
      }
    } else if (message.toLowerCase().contains('available time slots')) {
      // Extract department, service, and date from the message
      String department = _extractDepartment(message);
      String service = _extractService(message);
      String date = _extractDate(message);
      if (department.isNotEmpty && service.isNotEmpty && date.isNotEmpty) {
        List<String> availableTimeSlots = await getAvailableTimeSlots(department, service, date);
        if (availableTimeSlots.isNotEmpty) {
          return "Available time slots for $department, $service on $date are: ${availableTimeSlots.join(', ')}";
        } else {
          return "Sorry, there are no available time slots for $department, $service on $date.";
        }
      } else {
        return "Please specify the department, service, and date to check available time slots. For example, 'What are the available time slots for Health Aspect, Doctor's Appointment on 2023-07-01?'";
      }
    }

    // For more complex queries, use OpenAI API
    return await _getResponseFromOpenAI(message);
  }

  String _extractDepartment(String message) {
    if (message.toLowerCase().contains('health aspect')) return 'Health Aspect';
    if (message.toLowerCase().contains('wellness aspect')) return 'Wellness Aspect';
    return '';
  }

  String _extractService(String message) {
    if (message.toLowerCase().contains("doctor's appointment")) return "Doctor's Appointment";
    if (message.toLowerCase().contains('family planning')) return 'Family Planning';
    if (message.toLowerCase().contains('health consultation')) return 'Health Consultation';
    // Add more services as needed
    return '';
  }

  String _extractDate(String message) {
    // This is a simple date extraction. You might want to use a more robust method.
    RegExp dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    Match? match = dateRegex.firstMatch(message);
    return match != null ? match.group(0)! : '';
  }

  Future<String> _getResponseFromOpenAI(String message) async {
    const apiKey =
        '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'; // Replace with your actual API key
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant for the InQ application, a wellness center app for Central University of Technology students. Provide information about the app's features, booking appointments, managing appointments, and general wellness tips. You can also help users check available dates and time slots for appointments. Remind users that they can ask about available dates by specifying the department and service, and about available time slots by specifying the department, service, and date. Only answer questions related to the InQ app and its services. If asked about anything unrelated, politely redirect the conversation to the app's features."
            },
            {"role": "user", "content": message}
          ],
          "max_tokens": 150,
          "temperature": 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'Sorry, I encountered an error while processing your request.';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  void _askIfSatisfied() {
    setState(() {
      _messages
          .add(ChatMessage(text: "Was this answer helpful?", isUser: false));
      _isSatisfied = true;
    });
  }

  void _handleSatisfactionResponse(bool isSatisfied) {
    setState(() {
      if (isSatisfied) {
        _messages.add(ChatMessage(
            text:
                "Great! 😁 If you have any more questions, feel free to ask. 😎",
            isUser: false));
      } else {
        _messages.add(ChatMessage(
            text:
                "I'm sorry the answer wasn't helpful. For more information, please email us at Wellness@cut.ac.za.",
            isUser: false));
      }
      _isSatisfied = false;
    });
  }

  Future<List<String>> getAvailableDates(String department, String service) async {
    List<String> availableDates = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Availability')
          .doc(department)
          .collection('Services')
          .doc(service)
          .collection('Dates')
          .get();

      for (var doc in snapshot.docs) {
        availableDates.add(doc.id);
      }
    } catch (e) {
      print('Error fetching available dates: $e');
    }
    return availableDates;
  }

  Future<List<String>> getAvailableTimeSlots(String department, String service, String date) async {
    List<String> availableTimeSlots = [];
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Availability')
          .doc(department)
          .collection('Services')
          .doc(service)
          .collection('Dates')
          .doc(date)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data.forEach((key, value) {
          if (value == true) {
            availableTimeSlots.add(key);
          }
        });
      }
    } catch (e) {
      print('Error fetching available time slots: $e');
    }
    return availableTimeSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chat with InQBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_isSatisfied)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _handleSatisfactionResponse(true),
                  child: const Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () => _handleSatisfactionResponse(false),
                  child: const Text('No'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      fillColor: Colors.orange.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      hintText: 'Ask about Wellness...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({Key? key, required this.text, required this.isUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isUser ? Colors.orange : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Text(
              text,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
