import 'dart:core';
import 'package:flutter/material.dart';

//Email Notifier
class EmailNotifier with ChangeNotifier {
  Map<String, String> _emails = {};
  List<Map<String, dynamic>> _datetimeList = [];

  Map<String, String> get emails => _emails;
  int get emailCount => _emails.length;
  List get dateTimeList => _datetimeList;

  void addEmail(String key, String email) {
    _emails[key] = email;
    notifyListeners();
  }

  void removeEmail(String key) {
    _emails.remove(key);
    notifyListeners();
  }

  void updateEmail(String key, String newEmail) {
    _emails[key] = newEmail;
    notifyListeners();
  }

  void addDateTime(Map<String, dynamic> datetime) {
    _datetimeList.add(datetime);
    notifyListeners();
  }
}

//Feedback Notifier
class FeedbackNotifier with ChangeNotifier {
  List<Map<String, dynamic>> _feedbackList = [];
  double _averageStarRating = 0.0;

  List<Map<String, dynamic>> get feedbackList => _feedbackList;
  double get averageStarRating => _averageStarRating;

  void addFeedback(Map<String, dynamic> feedback) {
    _feedbackList.add(feedback);
    _updateAverageStarRating();
    notifyListeners();
  }

  void _updateAverageStarRating() {
    double totalStars = 0;
    for (var feedback in _feedbackList) {
      totalStars += feedback['stars'];
    }
    _averageStarRating = totalStars / _feedbackList.length;
  }
}