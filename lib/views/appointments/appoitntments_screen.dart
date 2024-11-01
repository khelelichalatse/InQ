import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:inq_app/views/appointments/appointment_info.dart';
import 'package:inq_app/views/appointments/rating_services.dart';
import 'package:inq_app/models/appointment_model.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:inq_app/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreService firestoreService = FirestoreService();
  int _selectedFilterIndex = 1; // 0 -> All, 1 -> Upcoming, 2 -> Past
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.initialize();
  }

  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    switch (_selectedFilterIndex) {
      case 0: // All
        return appointments;
      case 1: // Upcoming
        return appointments
            .where((appointment) => appointment.status != 'Completed')
            .toList();
      case 2: // Past
        return appointments
            .where((appointment) => appointment.status == 'Completed')
            .toList();
      default:
        return appointments;
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<String> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminderTime') ?? '1 hour before';
  }

  void _scheduleReminder(Appointment appointment) {
    final reminderTime =
        appointment.appointmentDate.subtract(Duration(hours: 1));
    print(
        'Scheduling reminder for: ${appointment.service} at ${reminderTime.toString()}');

    notificationService.scheduleNotification(
      id: appointment.appointmentReferenceNumber.hashCode,
      title: 'Upcoming Appointment Reminder',
      body: 'You have an appointment for ${appointment.service} in 1 hour',
      scheduledNotificationDateTime: reminderTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadReminderTime(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              // Filter Section
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.08,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: MediaQuery.of(context).size.width * 0.025,
                        offset: Offset(
                            0, MediaQuery.of(context).size.height * 0.005),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    child: ToggleButtons(
                      constraints: BoxConstraints(
                        minWidth: (MediaQuery.of(context).size.width * 0.8) / 3,
                        minHeight: MediaQuery.of(context).size.height * 0.05,
                      ),
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.06,
                      ),
                      renderBorder: false,
                      selectedBorderColor: Colors.transparent,
                      fillColor: Theme.of(context).colorScheme.primary,
                      selectedColor: Colors.white,
                      color: Colors.grey[600],
                      isSelected: [
                        _selectedFilterIndex == 0,
                        _selectedFilterIndex == 1,
                        _selectedFilterIndex == 2,
                      ],
                      onPressed: (int newIndex) {
                        setState(() => _selectedFilterIndex = newIndex);
                      },
                      children: [
                        _buildFilterButton('All'),
                        _buildFilterButton('Upcoming'),
                        _buildFilterButton('Past'),
                      ],
                    ),
                  ),
                ),
              ),

              // Appointments List
              Expanded(
                child: StreamBuilder<List<Appointment>>(
                  stream: firestoreService.getUserAppointments(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(context);
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState(context);
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    final appointments = _filterAppointments(snapshot.data!);
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        return AppointmentCard(
                          appointment: appointments[index],
                          onTap: () =>
                              _showAppointmentDetails(appointments[index]),
                          onFeedbackTap: () =>
                              _handleFeedbackTap(context, appointments[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentInfo()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Book Appointment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            elevation: 6,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFilterIcon(text),
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015),
          Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return Icons.list_alt_rounded;
      case 'Upcoming':
        return Icons.upcoming_rounded;
      case 'Past':
        return Icons.history_rounded;
      default:
        return Icons.list_alt_rounded;
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitRipple(
            color: Theme.of(context).colorScheme.primary,
            size: 60.0,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading appointments...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to book one',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {}); // Refresh the page
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfReviewExists(String? appointmentReferenceNumber) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final querySnapshot = await _firestore
        .collection('Users')
        .doc('Students')
        .collection('CUT')
        .doc(user.uid)
        .collection('Ratings')
        .where('appointmentInfo.appointmentReferenceNumber',
            isEqualTo: appointmentReferenceNumber)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void _handleFeedbackTap(BuildContext context, Appointment appointment) async {
    final bool reviewExists =
        await _checkIfReviewExists(appointment.appointmentReferenceNumber);

    if (reviewExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You have already submitted feedback for this appointment.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceRating(appointment: appointment),
        ),
      );
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${appointment.service}'),
            Text('Department: ${appointment.department}'),
            Text(
                'Appointment Date: ${DateFormat('dd MMM yyyy').format(appointment.appointmentDate)}'),
            Text(
                'Appointment Reference Number: ${appointment.appointmentReferenceNumber}'),
            Text(appointment.appointmentDate.isAfter(DateTime.now())
                ? "Status: Upcoming"
                : "Status: Past"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _confirmCancellation(appointment);
            },
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () async {
              // Close the confirmation dialog immediately
              Navigator.of(context).pop();

              // Show the Lottie animation dialog immediately
              _showLottieAnimation(
                animationPath: 'assets/success_tick.json',
                message: 'Cancelling appointment...',
                color: Colors.orange,
              );

              try {
                // Perform the cancellation
                await FirestoreService().cancelAppointment(appointment);

                // Update the animation to show success
                if (mounted) {
                  Navigator.of(context).pop(); // Remove the loading animation
                  _showLottieAnimation(
                    animationPath: 'assets/success_tick.json',
                    message: 'Appointment cancelled successfully',
                    color: Colors.green,
                  );
                }
              } catch (error) {
                // Show error animation if something goes wrong
                if (mounted) {
                  Navigator.of(context).pop(); // Remove the loading animation
                  _showLottieAnimation(
                    animationPath: 'assets/Cross.json',
                    message: 'Error cancelling appointment: $error',
                    color: Colors.red,
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showLottieAnimation({
    required String animationPath,
    required String message,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while processing
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              animationPath,
              height: 100,
              width: 100,
              repeat: message
                  .contains('Cancelling'), // Only repeat for loading state
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (!message.contains(
              'Cancelling')) // Only show close button for final states
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final VoidCallback onFeedbackTap;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onTap,
    required this.onFeedbackTap,
  }) : super(key: key);

  void _addAppointmentToCalendar(Appointment appointment) {
    final Event event = Event(
      title: appointment.service,
      description: appointment.department,
      location: 'Your appointment location', // Add location if applicable
      startDate: appointment.appointmentDate,
      endDate: appointment.appointmentDate
          .add(const Duration(hours: 1)), // Assuming 1-hour duration
      allDay: false,
    );

    Add2Calendar.addEvent2Cal(event);
  }

  Color _getStatusColor(Appointment appointment) {
    if (appointment.status.toLowerCase() == 'in progress') {
      return Colors.orange;
    }
    return appointment.status == 'Completed'
        ? Colors.red // Past/Completed appointments
        : Colors.green; // Upcoming appointments
  }

  String _getDisplayStatus(Appointment appointment) {
    if (appointment.status == 'Completed') {
      return 'Past';
    }
    if (appointment.status.toLowerCase() == 'in progress') {
      return 'Being Assisted';
    }
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    // Create a new DateTime that combines the date and time
    final DateTime combinedDateTime = DateTime(
      appointment.appointmentDate.year,
      appointment.appointmentDate.month,
      appointment.appointmentDate.day,
      appointment.appointmentTime.hour,
      appointment.appointmentTime.minute,
    );

    // Adjust for timezone if needed
    final localDateTime = combinedDateTime.toLocal();
    print('Local combined date time: $localDateTime');

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary, width: 0),
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Appointment Date",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.calendar_month),
                                  Text(DateFormat('dd-MM-yyyy')
                                      .format(localDateTime)),
                                ]),
                                const SizedBox(height: 5),
                                Row(children: [
                                  const Icon(Icons.access_time),
                                  Text(
                                      DateFormat('HH:mm').format(localDateTime))
                                ]),
                              ]),
                          const SizedBox(width: 30),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: _getStatusColor(appointment),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 7.0),
                                child: Text(
                                  _getDisplayStatus(appointment),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: const CircleAvatar(),
                      title: Text(
                        appointment.service,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(appointment.department),
                      trailing: appointment.status == 'Completed'
                          ? IconButton(
                              icon: const Icon(Icons.feedback),
                              onPressed: onFeedbackTap)
                          : null,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      appointment.status != 'Completed'
                          ? TextButton.icon(
                              onPressed: () {
                                _addAppointmentToCalendar(appointment);
                              },
                              label: const Text("Add event to Calender"),
                              icon: const Icon(Icons.calendar_month),
                            )
                          : Container(),
                    ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
