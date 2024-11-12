import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inq_app/models/User_model.dart';
import 'package:inq_app/models/appointment_model.dart';
import 'package:inq_app/models/quick_updates_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserData?> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return UserData(
          uid: user.uid,
          name: data['Name'],
          email: data['Email'],
          studentId: data['StudentID'],
          phoneNumber: data['Phone Number'],
          imageUrl: data['imageUrl'],
        );
      }
    }
    return null;
  }

  CollectionReference getAppointmentCollection() {
    User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('appointments')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .collection('appointments');
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  Stream<List<Appointment>> getAppointments() {
    return getAppointmentCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Appointment.fromFirestore(doc);
      }).toList();
    });
  }

  String _determineAppointmentStatus(
      DateTime appointmentDate, TimeOfDay appointmentTime, String dbStatus) {
    DateTime now = DateTime.now();

    // Convert appointment time to DateTime for comparison
    DateTime fullAppointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    );

    // If the status is "Cancelled" in the database, return that
    if (dbStatus.toLowerCase() == 'cancelled') {
      return 'Cancelled';
    }

    // Check if the appointment is currently happening
    // (within the appointment hour)
    if (now.isAfter(fullAppointmentDateTime)) {
      return 'Past';
    }

    // If the appointment is not cancelled and not past, it's upcoming
    return 'Upcoming';
  }

  Future<DocumentSnapshot?> getLatestAppointment() async {
    try {
      QuerySnapshot querySnapshot = await getAppointmentCollection()
          .orderBy('Appointment Date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
    } catch (e) {
      print("Error fetching latest appointment: $e");
    }
    return null;
  }

  Future<Appointment?> getEarliestAppointment(
      String department, String service) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .doc(department)
          .collection(service)
          .orderBy('Appointment Date', descending: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Appointment.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching earliest appointment: $e');
    }
    return null;
  }

  Future<Appointment?> getUpcomingAppointment(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(userId)
          .collection('appointments')
          .where('Appointment Date', isGreaterThanOrEqualTo: now)
          .orderBy('Appointment Date')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return Appointment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting upcoming appointment: $e');
      return null;
    }
  }

  Future<void> cancelAppointment(Appointment appointment) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      // Update the appointment status in user's collection
      await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .collection('appointments')
          .doc(appointment.appointmentReferenceNumber)
          .delete();

      // Update the appointment status in appointments collection
      await _firestore
          .collection('appointments')
          .doc(appointment.department)
          .collection(appointment.service)
          .doc(appointment.appointmentReferenceNumber)
          .update({'Status': 'Cancelled'});

      // Update the time slot availability
      final timeSlotRef = _firestore
          .collection('Availability')
          .doc(appointment.department)
          .collection('Services')
          .doc(appointment.service)
          .collection('Dates')
          .doc(DateFormat('yyyy-MM-dd').format(appointment.appointmentDate));

      final timeSlotDoc = await timeSlotRef.get();
      if (timeSlotDoc.exists) {
        Map<String, dynamic> slots =
            Map<String, dynamic>.from(timeSlotDoc.data()!);
        String timeKey =
            '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}';

        if (slots.containsKey(timeKey)) {
          slots[timeKey] = true; // Make the time slot available again
          await timeSlotRef.update(slots);
        }
      }

      print('Appointment cancelled successfully');
    } catch (e) {
      print('Error in cancelAppointment: $e');
      throw 'Failed to cancel appointment: $e';
    }
  }

  // Helper method to convert time string to TimeOfDay
  TimeOfDay _convertStringToTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> addRating({
    required Map<String, String> questionRatings, // Ratings for each question
    required String comment,
    required Appointment appointment,
  }) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // Prepare the feedback data with ratings for each question
      Map<String, dynamic> feedbackData = {
        'questionRatings': questionRatings,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'appointmentInfo': {
          'appointmentDate': appointment.appointmentDate,
          'appointmentTime': {
            'hour': appointment.appointmentTime.hour,
            'minute': appointment.appointmentTime.minute,
          },
          'patientName': appointment.patientName,
          'studentId': appointment.studentId,
          'service': appointment.service,
          'department': appointment.department,
          'appointmentReferenceNumber': appointment.appointmentReferenceNumber,
        },
      };

      // Store the feedback in the user's ratings sub-collection
      await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .collection('Ratings') // Sub-collection for ratings
          .add(feedbackData);

      await _firestore.collection('Ratings').add(feedbackData);

      print("Rating added successfully.");
    } catch (e) {
      print("Error adding rating: $e");
      throw e;
    }
  }

  Future<String> generateReferenceNumber(
      String selectedDate, String department, String service) async {
    try {
      // Format the date for reference number
      String formattedDate =
          DateFormat("yyMMdd").format(DateTime.parse(selectedDate));

      // Query Firestore to get all appointments for the same date, department, and service
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .doc(department)
          .collection(service)
          .where('Appointment Date', isEqualTo: DateTime.parse(selectedDate))
          .get();

      // Variable to keep track of the highest existing reference number
      int highestReferenceNumber = 99; // Start below the minimum of 100

      // Determine the prefix based on department and service
      String prefix = _getPrefix(department, service);

      // RegExp to match our reference number format
      RegExp regex = RegExp(r'^' + prefix + formattedDate + r'(\d{3})$');

      // Loop through the documents to find the highest existing appointmentReferenceNumber
      for (var doc in querySnapshot.docs) {
        String refNumber = doc['AppointmentReferenceNumber'] as String;
        Match? match = regex.firstMatch(refNumber);

        if (match != null) {
          String numericPart = match.group(1)!;
          int currentRefNumber = int.parse(numericPart);
          if (currentRefNumber > highestReferenceNumber) {
            highestReferenceNumber = currentRefNumber;
          }
        }
      }

      // Increment the highest reference number to generate the new one
      int newReferenceNumber = highestReferenceNumber + 1;

      // If the new number exceeds 300, reset to 100
      if (newReferenceNumber > 300) {
        newReferenceNumber = 100;
      }

      // Generate the new appointment reference number
      String appointmentReferenceNumber =
          "$prefix$formattedDate${newReferenceNumber.toString().padLeft(3, '0')}";

      return appointmentReferenceNumber;
    } catch (e) {
      print('Error generating reference number: $e');
      throw Exception('Failed to generate reference number: $e');
    }
  }

  String _getPrefix(String department, String service) {
    if (department == "Health Aspect") {
      if (service == "Doctor's Appointment") return "DRA";
      if (service == "Family Planning") return "FP";
      if (service == "Health Consultation") return "HC";
      return "UNK";
    } else if (department == "Wellness Aspect") {
      if (service == "Individual Session(Social Worker)") return "ISS";
      if (service == "Individual Session(Psychologist)") return "ISP";
      if (service == "Group Session(Social Worker)") return "GSS";
      if (service == "Group Session(Psychologist)") return "GSP";
      if (service == "N+ Rule Student") return "N+";
      if (service == "Unfunded Student") return "UN";
      return "UNK";
    }
    return "REF";
  }

  Future<void> bookAppointment(
      String department, String service, String date, String timeSlot,
      {String? referenceNumber}) async {
    // Get the user's preferred reminder duration
    Duration reminderBefore = await getPreferredReminderDuration();

    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final DocumentReference slotRef = _firestore
          .collection('Availability')
          .doc(department)
          .collection('Services')
          .doc(service)
          .collection('Dates')
          .doc(date);

      bool timeSlotBooked = false;

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(slotRef);

        if (!snapshot.exists) {
          throw Exception('No available slots for this date');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        if (data[timeSlot] == true) {
          transaction.update(slotRef, {timeSlot: false});
          timeSlotBooked = true;
        } else {
          timeSlotBooked = false;
        }
      });

      if (!timeSlotBooked) {
        throw Exception('Time slot is not available');
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User details not found');
      }

      String appointmentReferenceNumber =
          await generateReferenceNumber(date, department, service);
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Parse the date and time for notification
      final appointmentDate = DateTime.parse(date);
      final timeParts = timeSlot.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Create timestamp for the exact appointment time
      final appointmentTimestamp = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        hours,
        minutes,
      );

      // Calculate reminder time based on user preference
      final reminderTimestamp = appointmentTimestamp.subtract(reminderBefore);

      Map<String, dynamic> appointmentData = {
        'Patient Name': "${userData['Name']} ${userData['Surname']}",
        'StudentID': userData['StudentID'],
        'Department': department,
        'Service': service,
        'Appointment Date': DateTime.parse(date),
        'AppointmentReferenceNumber': appointmentReferenceNumber,
        'userId': user.uid,
        'TimeSlot': timeSlot,
        'Status': 'Upcoming',
        // Add these fields for notifications
        // 'appointmentTimestamp': appointmentTimestamp,
        // 'reminderTimestamp': reminderTimestamp,
        // 'reminderDuration': reminderBefore.inMinutes,
        // 'notificationSent': false,
        // 'fcmToken':
        //     await FirebaseMessaging.instance.getToken(), // Store FCM token
      };

      // Update both documents with the new fields
      await _firestore
          .collection('appointments')
          .doc(department)
          .collection(service)
          .doc(appointmentReferenceNumber)
          .set(appointmentData);

      await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(user.uid)
          .collection('appointments')
          .doc(appointmentReferenceNumber)
          .set(appointmentData);

      print(
          'Appointment booked successfully with reference number: $appointmentReferenceNumber');
    } catch (ex) {
      print('Error adding and booking appointment: $ex');
      throw ex;
    }
  }

  Future<List<String>> getAvailableTimeSlots(
      String department, String service, String date) async {
    // Implement the logic to fetch available time slots from Firestore
    // This is a placeholder implementation
    // Replace this with actual Firestore queries
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Availability')
          .doc(department)
          .collection('Services')
          .doc(service)
          .collection('Dates')
          .doc(date)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<String> availableSlots = data.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();
        return availableSlots;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching available time slots: $e');
      return [];
    }
  }

  Future<Duration> getPreferredReminderDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes =
        prefs.getInt('reminderMinutes') ?? 1440; // Default to 24 hours
    return Duration(minutes: minutes);
  }

  Stream<List<Appointment>> getUserAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('Users')
        .doc('Students')
        .collection('CUT')
        .doc(user.uid)
        .collection('appointments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }
}

class QuickUpdatesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QuickUpdate>> getQuickUpdates({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('QuickUpdates')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => QuickUpdate.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching quick updates: $e');
      return [];
    }
  }
}

class AvailabilityService {
  Future<void> initializeBusinessDaysForYear() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define the current year
    final int currentYear = DateTime.now().year;

    // Check if the business days have already been initialized for this year
    final doc = await firestore
        .collection('Availability')
        .doc('InitializationStatus')
        .get();

    if (doc.exists && doc.data()?['year'] == currentYear) {
      // Business days for this year are already initialized, no need to reinitialize
      print("Business days already initialized for the year $currentYear");
      return;
    }

    // Initialize the business days and time slots for each department/service
    final Map<String, Map<String, List<TimeOfDay>>> defaultTimeSlots = {
      'Health Aspect': {
        "Doctor's Appointment": [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 8, minute: 10),
          const TimeOfDay(hour: 8, minute: 20),
          const TimeOfDay(hour: 8, minute: 30),
          const TimeOfDay(hour: 8, minute: 40),
          const TimeOfDay(hour: 8, minute: 50),
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 9, minute: 10),
          const TimeOfDay(hour: 9, minute: 20),
          const TimeOfDay(hour: 9, minute: 30),
          const TimeOfDay(hour: 9, minute: 40),
          const TimeOfDay(hour: 9, minute: 50),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 10, minute: 10),
          const TimeOfDay(hour: 10, minute: 20),
          const TimeOfDay(hour: 10, minute: 30),
        ],
        'Family Planning': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 9, minute: 15),
          const TimeOfDay(hour: 9, minute: 30),
          const TimeOfDay(hour: 9, minute: 45),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 10, minute: 15),
          const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 45),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 11, minute: 15),
          const TimeOfDay(hour: 11, minute: 30),
          const TimeOfDay(hour: 11, minute: 45),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 12, minute: 15),
          const TimeOfDay(hour: 12, minute: 30),
          const TimeOfDay(hour: 12, minute: 45),
          const TimeOfDay(
              hour: 14, minute: 0), // Lunch break from 13:30 to 14:00
          const TimeOfDay(hour: 14, minute: 15),
          const TimeOfDay(hour: 14, minute: 30),
          const TimeOfDay(hour: 14, minute: 45),
          const TimeOfDay(hour: 15, minute: 0),
          const TimeOfDay(hour: 15, minute: 15),
          const TimeOfDay(hour: 15, minute: 30),
        ],
        'Health Consultation': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 9, minute: 30),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 11, minute: 30),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 12, minute: 30),
          const TimeOfDay(
              hour: 14, minute: 0), // Lunch break from 13:30 to 14:00
          const TimeOfDay(hour: 14, minute: 30),
          const TimeOfDay(hour: 15, minute: 0),
        ],
      },
      'Wellness Aspect': {
        'Individual Session(Social Worker)': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'Individual Session(Psychologist)': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'Group Session(Social Worker)': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'Group Session(Psychologist)': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'Fruit Nutrition': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'N+ Rule Student': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
        'Unfunded Student': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ],
      }
    };

    // Loop through each day of the year and initialize the time slots
    for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
      DateTime date = DateTime(currentYear).add(Duration(days: dayOffset));
      String formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Loop through each department and service to set up availability
      for (var departmentEntry in defaultTimeSlots.entries) {
        String department = departmentEntry.key;
        Map<String, List<TimeOfDay>> services = departmentEntry.value;

        for (var serviceEntry in services.entries) {
          String service = serviceEntry.key;
          List<TimeOfDay> timeSlots = serviceEntry.value;

          Map<String, bool> timeSlotsMap = {
            for (var slot in timeSlots) formatTimeOfDay(slot): true,
          };

          // Write to Firestore
          await firestore
              .collection('Availability')
              .doc(department)
              .collection('Services')
              .doc(service)
              .collection('Dates')
              .doc(formattedDate)
              .set(timeSlotsMap);
        }
      }
    }

    // Mark the year as initialized
    await firestore
        .collection('Availability')
        .doc('InitializationStatus')
        .set({'year': currentYear});
  }

// Helper to format TimeOfDay
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
