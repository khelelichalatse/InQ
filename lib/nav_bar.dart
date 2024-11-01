import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inq_app/views/appointments/appoitntments_screen.dart';
import 'package:inq_app/views/dashboard/dashboard.dart';
import 'package:inq_app/views/emails/email_layout.dart';
import 'package:inq_app/views/profile/settings.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();
  Set<String> _selectedEmails = <String>{};
  bool _isEmailSelectionMode = false;

  List<String> titles = [
    '',
    'Appointments',
    'Emails',
    'Profile',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleEmailSelectionMode(bool isSelected) {
    setState(() {
      _isEmailSelectionMode = isSelected;
    });
  }

  void updateSelectedEmails(Set<String> emails) {
    setState(() {
      _selectedEmails = emails;
    });
  }

  void deleteSelectedEmails(Set<String> emailIds) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      for (String emailId in emailIds) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc('Students')
            .collection('CUT')
            .doc(currentUser.uid)
            .collection('Emails')
            .doc(emailId)
            .delete();
      }
      setState(() {
        _selectedEmails.clear();
        _isEmailSelectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const Dashboard(),
      const AppointmentScreen(),
      EmailLayout(
        onSelectionModeChanged: toggleEmailSelectionMode,
        selectedEmails: _selectedEmails,
        onSelectedEmailsChanged: updateSelectedEmails,
        onDeleteEmails: deleteSelectedEmails,
      ),
      const Profile(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          titles[currentPageIndex],
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: _isEmailSelectionMode && currentPageIndex == 2
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    deleteSelectedEmails(_selectedEmails);
                  },
                ),
              ]
            : null,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        indicatorColor: Colors.orange,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Appointment',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.email),
            icon: Icon(Icons.email_outlined),
            label: 'Emails',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
