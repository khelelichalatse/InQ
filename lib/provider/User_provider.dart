import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:inq_app/models/User_model.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';

class UserProvider with ChangeNotifier {
  UserData? _userData;
  final FirestoreService _firestoreService = FirestoreService();

  UserData? get userData => _userData;

  Future<UserData?> fetchUserData() async {
    try {
      _userData = await _firestoreService.fetchUserData();
      notifyListeners();
      return _userData;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
