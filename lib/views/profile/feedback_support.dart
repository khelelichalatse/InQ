import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class FeedbackSupport extends StatelessWidget {
  const FeedbackSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Feedback History',
            style: TextStyle(fontSize: SizeConfig.text(6))),
        elevation: 0,
      ),
      body: ResponsiveWidget(
        mobile: _buildBody(user, context),
        tablet: Center(
          child: SizedBox(
            width: SizeConfig.width(80), // 80% of screen width
            child: _buildBody(user, context),
          ),
        ),
        desktop: Center(
          child: SizedBox(
            width: SizeConfig.width(60), // 60% of screen width
            child: _buildBody(user, context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(User? user, BuildContext context) {
    return user == null
        ? _buildLoginPrompt()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc('Students')
                .collection('CUT')
                .doc(user.uid)
                .collection('Ratings')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.orange));
              }

              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              return _buildFeedbackList(snapshot.data!.docs);
            },
          );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: SizeConfig.text(8), color: Colors.orange.shade300),
          SizedBox(height: SizeConfig.height(2)),
          Text(
            'Please log in to view feedback history',
            style: TextStyle(
              fontSize: SizeConfig.text(2.2),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement login functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Log In', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: SizeConfig.text(8), color: Colors.red.shade300),
          SizedBox(height: SizeConfig.height(2)),
          Text(
            'Error: $error',
            style: TextStyle(
              fontSize: SizeConfig.text(2.2),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined,
              size: SizeConfig.text(20), color: Colors.grey.shade400),
          SizedBox(height: SizeConfig.height(2)),
          Text(
            'No feedback history available',
            style: TextStyle(
              fontSize: SizeConfig.text(4),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your feedback will appear here once you submit it',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final appointmentInfo = data['appointmentInfo'] as Map<String, dynamic>;
        final questionRatings = data['questionRatings'] as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Card(
            color: Theme.of(context).colorScheme.onTertiary,
            margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.width(4),
              vertical: SizeConfig.height(1),
            ),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                appointmentInfo['service'] ?? 'Unknown Service',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                _formatTimestamp(data['timestamp'] as Timestamp),
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Text(
                  _calculateAverageRating(questionRatings).toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Department',
                          appointmentInfo['department'] ?? 'Unknown'),
                      _buildInfoRow(
                          'Ref',
                          appointmentInfo['appointmentReferenceNumber'] ??
                              'N/A'),
                      const Divider(),
                      const Text(
                        'Ratings:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ...questionRatings.entries
                          .map((entry) =>
                              _buildRatingRow(entry.key, entry.value))
                          .toList(),
                      const Divider(),
                      const Text(
                        'Comment:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(data['comment'] ?? 'No comment provided'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String question, String rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question)),
          _buildRatingChip(rating),
        ],
      ),
    );
  }

  Widget _buildRatingChip(String rating) {
    Color chipColor;
    switch (rating) {
      case 'EXCELLENT':
        chipColor = Colors.green;
        break;
      case 'GOOD':
        chipColor = Colors.lime;
        break;
      case 'AVERAGE':
        chipColor = Colors.orange;
        break;
      case 'POOR':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(rating,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('MMM d, yyyy - HH:mm').format(timestamp.toDate());
  }

  double _calculateAverageRating(Map<String, dynamic> questionRatings) {
    final ratings = questionRatings.values.map((rating) {
      switch (rating) {
        case 'EXCELLENT':
          return 5.0;
        case 'GOOD':
          return 4.0;
        case 'AVERAGE':
          return 3.0;
        case 'POOR':
          return 2.0;
        default:
          return 0.0;
      }
    });
    return ratings.isNotEmpty
        ? ratings.reduce((a, b) => a + b) / ratings.length
        : 0.0;
  }
}


