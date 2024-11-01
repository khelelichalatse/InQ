import 'package:flutter/material.dart';
import 'package:inq_app/models/appointment_model.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class ServiceRating extends StatefulWidget {
  final Appointment appointment;

  const ServiceRating({Key? key, required this.appointment}) : super(key: key);

  @override
  State<ServiceRating> createState() => _ServiceRatingState();
}

class _ServiceRatingState extends State<ServiceRating> {
  final List<String> _questions = [
    'I was satisfied with the services.',
    'I was handled and treated professionally.',
    'Staff was able to address my problem.',
    'The clinic is clean and tidy.',
    'Staff was friendly.',
    'I will refer my friends to the clinic.',
    'I will use the clinic again in the future.',
  ];

  final List<String> _ratings = ['EXCELLENT', 'GOOD', 'AVERAGE', 'POOR'];
  final List<int> _selectedRatings = List.filled(7, -1); // Initialize with -1
  final TextEditingController commentController = TextEditingController();
  final FirestoreService _firestoreService =
      FirestoreService(); // Firestore Service for submitting feedback

  Widget _buildRatingButton(int questionIndex, int ratingIndex, String rating) {
    bool isSelected = _selectedRatings[questionIndex] == ratingIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRatings[questionIndex] = ratingIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width(3),
          vertical: SizeConfig.height(1),
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(SizeConfig.width(5)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Text(
          rating,
          style: TextStyle(
            fontSize: SizeConfig.text(3),
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.height(2)),
      child: Row(
        children: [
          Expanded(child: _buildDividerLine()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(2)),
            child: Container(
              padding: EdgeInsets.all(SizeConfig.width(1)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.feedback_outlined,
                size: SizeConfig.text(4),
                color: Colors.orange,
              ),
            ),
          ),
          Expanded(child: _buildDividerLine()),
        ],
      ),
    );
  }

  Widget _buildDividerLine() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange.withOpacity(0.5), Colors.white],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    // Create a map of question to its corresponding rating
    Map<String, String> questionRatings = {};

    for (int i = 0; i < _questions.length; i++) {
      // Skip if the rating is not selected (-1 indicates no rating selected)
      if (_selectedRatings[i] != -1) {
        questionRatings[_questions[i]] = _ratings[_selectedRatings[i]];
      }
    }

    try {
      await _firestoreService.addRating(
        questionRatings: questionRatings, // Pass the question-to-rating map
        comment: commentController.text,
        appointment: widget.appointment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Rating',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeConfig.text(6),
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ResponsiveWidget(
        mobile: _buildContent(),
        tablet: Center(
          child: SizedBox(
            width: SizeConfig.width(80), // 80% of screen width
            child: _buildContent(),
          ),
        ),
        desktop: Center(
          child: SizedBox(
            width: SizeConfig.width(60), // 60% of screen width
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please rate our services:',
              style: TextStyle(
                fontSize: SizeConfig.text(4),
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: SizeConfig.height(2)),

            // Iterate through questions and ratings
            ..._questions.asMap().entries.map((entry) {
              int index = entry.key;
              String question = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: TextStyle(
                      fontSize: SizeConfig.text(3),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: SizeConfig.height(1)),
                  Wrap(
                    spacing: SizeConfig.width(2),
                    runSpacing: SizeConfig.height(1),
                    children: _ratings.asMap().entries.map((ratingEntry) {
                      int ratingIndex = ratingEntry.key;
                      String rating = ratingEntry.value;
                      return _buildRatingButton(index, ratingIndex, rating);
                    }).toList(),
                  ),
                  if (index < _questions.length - 1) _buildDivider(),
                ],
              );
            }).toList(),

            SizedBox(height: SizeConfig.height(2.5)),

            Text(
              'Supporting comments:',
              style: TextStyle(
                fontSize: SizeConfig.text(3),
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SizeConfig.width(2.5)),
              child: TextField(
                controller: commentController,
                style: TextStyle(fontSize: SizeConfig.text(3)),
                decoration: InputDecoration(
                  hintText: 'Your comments here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.width(5)),
                  ),
                ),
                maxLines: 3,
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.width(10),
                    vertical: SizeConfig.height(2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.width(7.5)
                    ),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: SizeConfig.text(3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
