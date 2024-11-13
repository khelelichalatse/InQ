import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/timeline_progress_indicator.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'package:inq_app/views/appointments/confirm_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckAvailability extends StatefulWidget {
  const CheckAvailability({super.key});

  @override
  _CheckAvailabilityState createState() => _CheckAvailabilityState();
}

class _CheckAvailabilityState extends State<CheckAvailability> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = []; // Remove the 'final' keyword

  @override
  void initState() {
    super.initState();
    // Ensure the initial date is a valid weekday
    _selectedDate = _getNextWeekday(DateTime.now());
  }

  // Helper function to get the next available weekday
  DateTime _getNextWeekday(DateTime date) {
    while (
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  // Fetch available time slots from Firestore based on the selected date
  Future<void> fetchAvailableTimeSlots() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      List<String> slots = await appointmentProvider.getAvailableTimeSlots(
        appointmentProvider.department,
        appointmentProvider.service,
        formattedDate
      );
      setState(() {
        _availableTimeSlots = slots; // Now this assignment is valid
      });
      _showAvailableTimeSlotsDialog();
    } catch (e) {
      print('Error fetching time slots: $e');
    }
  }

  // Show the available time slots as a dialog
  void _showAvailableTimeSlotsDialog() {
    // Convert time slots to DateTime objects for sorting
    List<DateTime> sortedTimeSlots = _availableTimeSlots.map((timeSlot) {
      // Assuming timeSlot is in "HH:mm" format
      return DateFormat("HH:mm").parse(timeSlot);
    }).toList();

    // Sort the time slots
    sortedTimeSlots.sort((a, b) => a.compareTo(b));

    // Convert the sorted DateTime back to the original format
    List<String> sortedTimeSlotsString = sortedTimeSlots
        .map((timeSlot) => DateFormat("HH:mm").format(timeSlot))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Available Time Slots'),
          content: Container(
            width: double.maxFinite,
            height: 250,
            child: sortedTimeSlotsString.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      childAspectRatio: 3, // Adjust height of each button
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: sortedTimeSlotsString.length,
                    itemBuilder: (BuildContext context, int index) {
                      String timeSlot = sortedTimeSlotsString[index];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTimeSlot == timeSlot
                              ? Colors.orange
                              : Colors.white,
                          foregroundColor: _selectedTimeSlot == timeSlot
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedTimeSlot = timeSlot;
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text(
                          timeSlot,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                    'No available time slots.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Present date picker
  Future<void> _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          _getNextWeekday(DateTime.now()), // Ensure initial date is a weekday
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (date) {
        // Allow only weekdays
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      await fetchAvailableTimeSlots(); // Fetch new time slots based on the selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Availability',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const TimelineProgressIndicator(currentIndex: 2, totalSteps: 3),
              const SizedBox(height: 20),

              // Date picker displayed directly
              const Text('Select Appointment Date:'),
              const SizedBox(height: 10),
              CalendarDatePicker(
                initialDate: _selectedDate ?? _getNextWeekday(DateTime.now()),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (pickedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _selectedTimeSlot = null; // Reset time slot
                  });
                  fetchAvailableTimeSlots(); // Fetch time slots for the selected date
                },
                selectableDayPredicate: (date) {
                  return date.weekday >= DateTime.monday &&
                      date.weekday <= DateTime.friday; // Allow only weekdays
                },
              ),

              const SizedBox(height: 20),

              // Button to confirm the selected time slot
              ElevatedButton(
                onPressed: _selectedTimeSlot != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmDetailsScreen(
                              selectedDate: _selectedDate!,
                              selectedTimeSlot: _selectedTimeSlot!,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Confirm Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
