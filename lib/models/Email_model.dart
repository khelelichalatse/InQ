// Model class for handling email messages within the application
import 'package:cloud_firestore/cloud_firestore.dart';

class Email {
  final String id;        
  final String subject;   
  final String body;  
  final String sender;    
  final String recipient; 
  final DateTime timestamp; 

  Email({
    required this.id,
    required this.subject,
    required this.body,
    required this.sender,
    required this.recipient,
    required this.timestamp,
  });

  factory Email.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Email(
      id: doc.id,
      subject: data['subject'] ?? '',
      body: data['body'] ?? '',
      sender: data['sender'] ?? '',
      recipient: data['recipient'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'body': body,
      'sender': sender,
      'recipient': recipient,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
