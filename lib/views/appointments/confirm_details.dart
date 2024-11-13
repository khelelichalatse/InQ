import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/timeline_progress_indicator.dart';
import 'package:inq_app/provider/User_provider.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:inq_app/views/appointments/appointment_info.dart';
import 'package:inq_app/views/appointments/check_availability.dart';
import 'package:inq_app/views/profile/personal_info_updates.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:inq_app/services/twilio_service.dart';

class ConfirmDetailsScreen extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedTimeSlot;

  const ConfirmDetailsScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
  });

  // Handle appointment confirmation and submission
  void _confirmAppointment(BuildContext context) async {
    print("Confirming appointment..."); // Debug print
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firestoreService = FirestoreService();
    final twilioService = TwilioServiceSMS();

    if (userProvider.userData == null) {
      print("User data is null"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User data not available. Please try again.')),
      );
      return;
    }

    String selectedDateFormatted =
        DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      // Generate reference number before booking the appointment
      String appointmentReferenceNumber =
          await firestoreService.generateReferenceNumber(selectedDateFormatted,
              appointmentProvider.department, appointmentProvider.service);

      // Use the FirestoreService to book the appointment with the generated reference number
      await firestoreService.bookAppointment(
        appointmentProvider.department,
        appointmentProvider.service,
        selectedDateFormatted,
        selectedTimeSlot,
        referenceNumber: appointmentReferenceNumber,
      );

      print(
          "Appointment booked successfully with reference number: $appointmentReferenceNumber"); // Debug print

      // Send SMS confirmation
      String messageBody = '''Your appointment has been booked successfully.
Reference Number: $appointmentReferenceNumber
Date: $selectedDateFormatted
Time: $selectedTimeSlot
Department: ${appointmentProvider.department} 
Service: ${appointmentProvider.service}
    ''';

      await twilioService.sendSMS(
          userProvider.userData!.phoneNumber, messageBody);

      _showConfirmationDialog(context, appointmentReferenceNumber);
    } catch (e) {
      print("Error booking appointment: $e"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access providers for appointment and user data
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Fetch user data if not already loaded
    if (userProvider.userData == null) {
      userProvider.fetchUserData();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TimelineProgressIndicator(currentIndex: 3, totalSteps: 3),
              const SizedBox(height: 20),
              const Text(
                'Please Confirm The Following Details.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildAppointmentDetails(context, appointmentProvider),
              _buildPersonalDetails(context, userProvider),
              const SizedBox(height: 30),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(
      BuildContext context, AppointmentProvider appointmentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appointment Information'),
        _buildEditableRow(
          'Date',
          'Date: ${DateFormat("d MMM, EEEE").format(selectedDate)}',
          '',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckAvailability()),
          ),
        ),
        _buildEditableRow(
          'Time Slot',
          'Selected Time: $selectedTimeSlot',
          '',
          () {
            // Add functionality if you want to allow editing of the time slot
          },
        ),
        _buildEditableRow(
          'Department & Service',
          'Department: ${appointmentProvider.department}',
          'Service: ${appointmentProvider.service}',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppointmentInfo()),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetails(
      BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.userData == null) {
              return const CircularProgressIndicator();
            } else {
              return _buildEditableRow(
                'Personal Details',
                'Name: ${userProvider.userData!.name}',
                'Phone Number: ${userProvider.userData!.phoneNumber}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileUpdateScreen()),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.orange),
      ),
    );
  }

  Widget _buildEditableRow(
      String title, String detail1, String detail2, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, color: Colors.orange)),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          ),
          if (detail1.isNotEmpty) Text(detail1),
          if (detail2.isNotEmpty) Text(detail2),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CheckAvailability()),
            );
          },
          child: const Text('Back', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () => _confirmAppointment(context),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String appointmentReferenceNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Booked Successfully'),
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    'Your appointment has been booked successfully. Your appointment number is:'),
                Text(
                  appointmentReferenceNumber,
                  style: const TextStyle(fontSize: 20, color: Colors.orange),
                ),
                const Text(
                    'We will also send you an SMS with your appointment number.'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/navBar', arguments: 1);
              },
            ),
          ],
        );
      },
    );
  }
}
