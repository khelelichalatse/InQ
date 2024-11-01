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

//AppointmentProvider Class with TimeSlot Refactor

/*class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  String _patientName = "";
  String _studentID = "";
  String _phoneNumber = "";
  String _department = "";
  String _service = "";
  DateTime _appointmentDate = DateTime.now();
  TimeOfDay? _appointmentTimeSlot;
  String _selectedFamilyPlanning15MinTimeSlot = "";

  String get patientName => _patientName;
  String get studentID => _studentID;
  String get phoneNumber => _phoneNumber;
  String get department => _department;
  String get service => _service;
  DateTime get appointmentDate => _appointmentDate;
  TimeOfDay? get appointmentTimeSlot => _appointmentTimeSlot;
  String get selectedFamilyPlanning15MinTimeSlot =>
      _selectedFamilyPlanning15MinTimeSlot;

  void setTimeAndDate(date, time) {
    _appointmentDate = date;
    _appointmentTimeSlot = time;
    notifyListeners();
  }

  void setFamilyPlanning15MinTimeSlot(
      String selectedFamilyPlanning15MinTimeSlot) {
    _selectedFamilyPlanning15MinTimeSlot = selectedFamilyPlanning15MinTimeSlot;
    notifyListeners();
  }

  void setPatientDetails(patientName, studentID, phoneNumber) {
    _patientName = patientName;
    _studentID = studentID;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setAppointmentDetails(department, service) {
    _department = department;
    _service = service;

    notifyListeners();
  }

  List<Appointment> get appointments => _appointments;

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

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void deleteAppointment(Appointment appointment) {
    appointments.remove(appointment);
    notifyListeners();
  }

//Welness
//   Map<TimeOfDay, int> getWellnessTimeSlots(DateTime date) {
//     Map<TimeOfDay, int> wellnessTimeSlots = {
//       const TimeOfDay(hour: 09, minute: 00): 0,
//       const TimeOfDay(hour: 10, minute: 00): 0,
//       const TimeOfDay(hour: 11, minute: 00): 0,
//       const TimeOfDay(hour: 12, minute: 00): 0,
//       // TimeOfDay(hour: 13, minute: 0), // lunch time
//       const TimeOfDay(hour: 14, minute: 00): 0,
//       const TimeOfDay(hour: 15, minute: 00): 0,
//     };

//     for (var appointment in _appointments) {
//       if (appointment.appointmentDate.year == date.year &&
//           appointment.appointmentDate.month == date.month &&
//           appointment.appointmentDate.day == date.day) {
//         TimeOfDay timeOfDay = TimeOfDay(
//           hour: appointment.appointmentTimeSlot!.hour,
//           minute: appointment.appointmentTimeSlot!.minute,
//         );
//         wellnessTimeSlots[timeOfDay] = (wellnessTimeSlots[timeOfDay] ?? 0) + 1;
//       }
//     }

//     return wellnessTimeSlots;
//   }

// //Doctors
//   Map<TimeOfDay, int> getDoctorsTimeSlots(DateTime date) {
//     Map<TimeOfDay, int> doctorsTimeSlots = {
//       const TimeOfDay(hour: 08, minute: 00): 0,
//       const TimeOfDay(hour: 08, minute: 10): 0,
//       const TimeOfDay(hour: 08, minute: 20): 0,
//       const TimeOfDay(hour: 08, minute: 30): 0,
//       const TimeOfDay(hour: 08, minute: 40): 0,
//       const TimeOfDay(hour: 08, minute: 50): 0,
//       const TimeOfDay(hour: 09, minute: 00): 0,
//       const TimeOfDay(hour: 09, minute: 10): 0,
//       const TimeOfDay(hour: 09, minute: 20): 0,
//       const TimeOfDay(hour: 09, minute: 30): 0,
//       const TimeOfDay(hour: 09, minute: 40): 0,
//     };

//     for (var appointment in _appointments) {
//       if (appointment.appointmentDate.year == date.year &&
//           appointment.appointmentDate.month == date.month &&
//           appointment.appointmentDate.day == date.day &&
//            appointment.service == "Doctor's Appointment" &&
//           appointment.department == "Health Aspect") {
//         TimeOfDay timeOfDay = TimeOfDay(
//           hour: appointment.appointmentTimeSlot!.hour,
//           minute: appointment.appointmentTimeSlot!.minute,
//         );
//         doctorsTimeSlots[timeOfDay] = (doctorsTimeSlots[timeOfDay] ?? 0) + 1;
//       }
//     }

//     return doctorsTimeSlots;
//   }

// //Family planning
//   Map<TimeOfDay, int> getFamilyPlanningTimeSlots(DateTime date) {
//     Map<TimeOfDay, int> familyPlanningTimeSlots = {
//       const TimeOfDay(hour: 09, minute: 00): 0,
//       const TimeOfDay(hour: 10, minute: 00): 0,
//       const TimeOfDay(hour: 11, minute: 00): 0,
//       const TimeOfDay(hour: 12, minute: 00): 0,
//       const TimeOfDay(hour: 14, minute: 00): 0,
//       const TimeOfDay(hour: 15, minute: 00): 0,
//     };

//     for (var appointment in _appointments) {
//       if (appointment.appointmentDate.year == date.year &&
//           appointment.appointmentDate.month == date.month &&
//           appointment.appointmentDate.day == date.day &&
//           appointment.service == "Family Planning" &&
//           appointment.department == "Health Aspect") {
//         TimeOfDay timeOfDay = TimeOfDay(
//           hour: appointment.appointmentTimeSlot!.hour,
//           minute: appointment.appointmentTimeSlot!.minute,
//         );
//         familyPlanningTimeSlots[timeOfDay] =
//             (familyPlanningTimeSlots[timeOfDay] ?? 0) + 1;
//       }
//     }

//     return familyPlanningTimeSlots;
//   }

// //Consultations
//   Map<TimeOfDay, int> getHealthConsultationTimeSlots(DateTime date) {
//     Map<TimeOfDay, int> healthConsultationTimeSlots = {
//       const TimeOfDay(hour: 09, minute: 00): 0,
//       const TimeOfDay(hour: 09, minute: 30): 0,
//       const TimeOfDay(hour: 10, minute: 00): 0,
//       const TimeOfDay(hour: 10, minute: 30): 0,
//       const TimeOfDay(hour: 11, minute: 00): 0,
//       const TimeOfDay(hour: 11, minute: 30): 0,
//       const TimeOfDay(hour: 12, minute: 00): 0,
//       const TimeOfDay(hour: 12, minute: 30): 0,
//       const TimeOfDay(hour: 13, minute: 00): 0,
//       // TimeOfDay(hour: 13, minute: 30), // lunch time
//       const TimeOfDay(hour: 14, minute: 00): 0,
//       const TimeOfDay(hour: 14, minute: 30): 0,
//       const TimeOfDay(hour: 15, minute: 00): 0,
//       const TimeOfDay(hour: 15, minute: 30): 0,
//       const TimeOfDay(hour: 16, minute: 00): 0,
//     };

//     for (var appointment in _appointments) {
//       if (appointment.appointmentDate.year == date.year &&
//           appointment.appointmentDate.month == date.month &&
//           appointment.appointmentDate.day == date.day &&
//           appointment.service == "Health Consultation" &&
//           appointment.department == "Health Aspect") {
//         TimeOfDay timeOfDay = TimeOfDay(
//           hour: appointment.appointmentTimeSlot!.hour,
//           minute: appointment.appointmentTimeSlot!.minute,
//         );
//         healthConsultationTimeSlots[timeOfDay] =
//             (healthConsultationTimeSlots[timeOfDay] ?? 0) + 1;
//       }
//     }

//     return healthConsultationTimeSlots;
//   }

//Function that checks if the time is AM or PM
 /* String formatTimeOfDay(TimeOfDay? time) {
  
  final hour = time!.hour;
  final stringHour = time.hour.toString().padLeft(2, '0');
  final stringMinute = time.minute.toString().padLeft(2, '0');
  final ampm = hour < 12 ? 'AM' : 'PM';
  String formattedTime = '$stringHour:$stringMinute $ampm';

if(service == "Family Planning")
{
  if(selectedFamilyPlanning15MinTimeSlot == "axactly at selected hour")
{
    formattedTime = '$stringHour:$stringMinute $ampm';
}
else if(selectedFamilyPlanning15MinTimeSlot == "15 minutes past")
{
  formattedTime = '$stringHour:15 $ampm';
}
else if(selectedFamilyPlanning15MinTimeSlot == "30 minutes past")
{
    formattedTime = '$stringHour:30 $ampm';
}
else
{
    formattedTime = '$stringHour:45 $ampm';

}

}
  return formattedTime;
}*/


 /* List<Appointment> get upcomingAppointments {
    DateTime now = DateTime.now();
    return _appointments
        .where((appointment) => appointment.appointmentDate.isAfter(now))
        .toList();
  }

  List<Appointment> get pastAppointments {
    DateTime now = DateTime.now();
    return _appointments
        .where((appointment) => appointment.appointmentDate.isBefore(now))
        .toList();

        
  }

  List<Appointment> get allAppointments => _appointments;
  List<String> get departments => _departments;
  Map<String, List<String>> get services => _services;
}*/

class UpdatesNotifier with ChangeNotifier {
  final List<QuickUpdate> _updatesList = [
    QuickUpdate(
      image: 'assets/image1.jpg',
      title: 'Image 1',
      content: 'This is the content of image 1',
    ),
    QuickUpdate(
      image: 'assets/image2.jpg',
      title: 'Image 2',
      content: 'This is the content of image 2',
    ),
    QuickUpdate(
      image: 'assets/image3.jpg',
      title: 'Image 3',
      content: 'This is the content of image 3',
    ),
    // Add more items to the list...
  ];
  int _currentIndex = 0;

  List<QuickUpdate> get updatesList => _updatesList;
  int get currentIndex => _currentIndex;
  void incrementCurrentIndex() {
    _currentIndex++;
    notifyListeners();
  }

  void decrementCurrentIndex() {
    _currentIndex--;
    notifyListeners();
  }

  Map<String, dynamic> _slot1 = {
    'title': 'Health Week Matters!',
    'content':
        'Campus Health Services has a professional nurse, a medical doctor and an HIV/AIDS counsellor on hand to provide medical services to staff and students.',
    'image': "assets/CUT_health.jpg",
  };
  Map<String, dynamic> _slot2 = {
    'title': 'Are your personal problems weighing you down?',
    'content':
        'The Wellness Centre will address these personal issues, as well as all stumbling blocks hindering your progress towards achieving academic success at CUT, through individual and/or group counselling sessions.',
    'image': "assets/psychologist.jpeg",
  };
  Map<String, dynamic> _slot3 = {
    'title':
        'TOV and SAB companies donate sanitary towels to CUT female students ',
    'content':
        'The Other Venue (TOV) and South African Brewery (SAB) donated sanitary towels to CUT female students as part of their Women\'s Month support campaign. ',
    'image': "assets/StudentSupport.jpg",
  };

  Map<String, dynamic> get updateSlot1 => _slot1;
  Map<String, dynamic> get updateSlot2 => _slot2;
  Map<String, dynamic> get updateSlot3 => _slot3;

  void setUpdateSlot1(Map<String, dynamic> update) {
    _slot1 = update;
    notifyListeners();
  }

  void setImage1(File image) {
    _slot1['image'] = image.path;
    notifyListeners();
  }

  void updateTitle1(String title) {
    _slot1['title'] = title;
    notifyListeners();
  }

  void updateContent1(String content) {
    _slot1['content'] = content;
    notifyListeners();
  }

//slot 2
  void setUpdateSlot2(Map<String, dynamic> update) {
    _slot2 = update;
    notifyListeners();
  }

  void setImage2(File image) {
    _slot2['image'] = image.path;
    notifyListeners();
  }

  void updateTitle2(String title) {
    _slot2['title'] = title;
    notifyListeners();
  }

  void updateContent2(String content) {
    _slot2['content'] = content;
    notifyListeners();
  }

//slot 3
  void setUpdateSlot3(Map<String, dynamic> update) {
    _slot3 = update;
    notifyListeners();
  }

  void setImage3(File image) {
    _slot3['image'] = image.path;
    notifyListeners();
  }

  void updateTitle3(String title) {
    _slot3['title'] = title;
    notifyListeners();
  }

  void updateContent3(String content) {
    _slot3['content'] = content;
    notifyListeners();
  }
}*/
