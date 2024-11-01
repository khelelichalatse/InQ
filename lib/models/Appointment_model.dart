import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Appointment {
  final String service;
  final String department;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String appointmentReferenceNumber;
  final String status;
  final String studentId; // Changed from studentID to match the constructor
  final String patientName;
  final String id;

  Appointment({
    required this.service,
    required this.department,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentReferenceNumber,
    required this.status,
    required this.studentId, // Changed parameter name to match
    required this.patientName,
    required this.id,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert the time string to TimeOfDay
    String timeSlot = data['TimeSlot'] as String;
    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Appointment(
      service: data['Service'] ?? '',
      department: data['Department'] ?? '',
      appointmentDate: (data['Appointment Date'] as Timestamp).toDate(),
      appointmentTime: TimeOfDay(hour: hour, minute: minute),
      appointmentReferenceNumber: data['AppointmentReferenceNumber'] ?? '',
      status: data['Status'] ?? 'In Progress',
      studentId: data['StudentID'] ?? '', // Match the field name in Firestore
      patientName: data['Patient Name'] ?? 'Unknown',
      id: doc.id,
    );
  }

  // Helper method to convert TimeOfDay to string format
  String get timeString {
    return '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}';
  }

  // Convert appointment to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'Service': service,
      'Department': department,
      'Appointment Date': Timestamp.fromDate(appointmentDate),
      'TimeSlot': timeString,
      'AppointmentReferenceNumber': appointmentReferenceNumber,
      'Status': status,
      'StudentID': studentId,
      'Patient Name': patientName,
    };
  }
}
