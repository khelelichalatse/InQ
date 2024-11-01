import 'package:flutter/material.dart';
import 'package:inq_app/models/Appointment_model.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppointmentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Appointment> _appointments = [];
  String _department = "";
  String _service = "";
  DateTime _appointmentDate = DateTime.now();

  String get department => _department;
  String get service => _service;
  DateTime get appointmentDate => _appointmentDate;

  void setDepartment(String department) {
    _department = department;
    notifyListeners();
  }

  void setService(String service) {
    _service = service;
    notifyListeners();
  }

  Future<void> setAppointmentDate(DateTime date) async {
    _appointmentDate = date;
    notifyListeners();
  }

  void setAppointmentDetails(String department, String service) {
    _department = department;
    _service = service;
    notifyListeners();
  }

  List<Appointment> get appointments => _appointments;
  List<String> get departments => _departments;
  Map<String, List<String>> get services => _services;

  // Add this method to generate reference numbers
  Future<String> generateReferenceNumber(String date, String department, String service) async {
    try {
      // Generate a unique reference number
      String dateStr = DateFormat('yyyyMMdd').format(DateTime.parse(date));
      String randomPart = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      return '$dateStr-$department-$service-$randomPart';
    } catch (e) {
      print('Error generating reference number: $e');
      throw Exception('Failed to generate reference number');
    }
  }

  // Add this method to get available time slots
  Future<List<String>> getAvailableTimeSlots(String department, String service, String date) async {
    return await _firestoreService.getAvailableTimeSlots(department, service, date);
  }

  final List<String> _departments = [
    'Health Aspect',
    'Wellness Aspect',
  ];

  final Map<String, List<String>> _services = {
    'Health Aspect': [
      "Doctor's Appointment",
      "Family Planning",
      "Health Consultation"
    ],
    'Wellness Aspect': [
      'Individual Session(Social Worker)',
      'Individual Session(Psychologist)',
      'Group Session(Social Worker)',
      'Group Session(Psychologist)',
      'Fruit Nutrition',
      'N+ Rule Student',
      'Unfunded Student',
    ],
  };

  Future<void> bookAppointment(String department, String service, String date, String timeSlot) async {
    try {
      // Generate reference number
      String referenceNumber = await generateReferenceNumber(date, department, service);

      // Book the appointment in Firestore
      await FirebaseFirestore.instance.collection('appointments').add({
        'referenceNumber': referenceNumber,
        'department': department,
        'service': service,
        'date': date,
        'timeSlot': timeSlot,
        'status': 'Upcoming',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Appointment booked successfully');
    } catch (e) {
      print('Error booking appointment: $e');
      throw Exception('Failed to book appointment: $e');
    }
  }
}
