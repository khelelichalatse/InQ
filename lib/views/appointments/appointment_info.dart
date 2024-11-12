import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/timeline_progress_indicator.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'package:inq_app/views/appointments/check_availability.dart';
import 'package:provider/provider.dart';

class AppointmentInfo extends StatefulWidget {
  @override
  State<AppointmentInfo> createState() => _AppointmentInfoState();
}

class _AppointmentInfoState extends State<AppointmentInfo> {
  String? selectedDepartment;
  String? selectedService;

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add the progress indicator
              const TimelineProgressIndicator(
                currentIndex: 0,
                totalSteps: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Please provide the Appointment Details',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Department Selection
              const Text('Select Appointment Type:'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                alignment: AlignmentDirectional.center,
                decoration: InputDecoration(
                  hintText: 'Select Department',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
                items: appointmentProvider.departments.map((department) {
                  return DropdownMenuItem(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                    selectedService = null; // Reset service selection
                  });
                },
                validator: (value) {
                  if (value == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a department'),
                      ),
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Service Selection
              const Text('Select Appointment Reason:'),
              const SizedBox(height: 10),
              selectedDepartment != null
                  ? DropdownButtonFormField<String>(
                      value: selectedService,
                      alignment: AlignmentDirectional.center,
                      decoration: InputDecoration(
                        hintText: 'Select Service',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      items: appointmentProvider.services[selectedDepartment!]!
                          .map((service) {
                        return DropdownMenuItem(
                          value: service,
                          child: Text(service),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedService = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a service'),
                            ),
                          );
                        }
                        return null;
                      },
                    )
                  : Container(),

              const SizedBox(height: 20),

              // Continue and Back Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      if (selectedDepartment != null &&
                          selectedService != null) {
                        appointmentProvider.setAppointmentDetails(
                            selectedDepartment!, selectedService!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckAvailability(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
