import 'package:cloud_firestore/cloud_firestore.dart';

class QuickUpdate {
  final String title;
  final String newsBody;
  final String imageUrl;
  final DateTime timestamp;

  QuickUpdate({
    required this.title,
    required this.newsBody,
    required this.imageUrl,
    required this.timestamp,
  });

  factory QuickUpdate.fromFirestore(Map<String, dynamic> data) {
    return QuickUpdate(
      title: data['title'] ?? '',
      newsBody: data['newsBody'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
