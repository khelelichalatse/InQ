import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/views/dashboard/gemini_chatbot_page.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:inq_app/views/dashboard/update_slider.dart';
import 'package:inq_app/models/appointment_model.dart';
import 'package:inq_app/views/appointments/appoitntments_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late List<Appointment> displayedAppointments;
  Appointment? latestAppointment;

  int index = 0;
  List screens = [
    const AppointmentScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLatestAppointment();
  }

  /// Fetch appointments from the provider when the screen is loaded
  Future<void> _fetchLatestAppointment() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      try {
        Appointment? appointment = await _firestoreService
            .getUpcomingAppointment(user.uid); // Pass user ID
        setState(() {
          latestAppointment = appointment; // Set the latest appointment
        });
      } catch (e) {
        print("Error fetching latest appointment: $e");
      }
    } else {
      print("No user is currently logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(appointmentProvider),
        tablet: _buildTabletLayout(appointmentProvider),
        desktop: _buildDesktopLayout(appointmentProvider),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GeminiChatbotPage()),
        ),
        backgroundColor: Colors.transparent,
        tooltip: 'Chat with AI',
        child: Image.asset("assets/chatbot.png"),
      ),
    );
  }

  Widget _buildMobileLayout(AppointmentProvider appointmentProvider) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          _buildHeaderBackground(),
          Padding(
            padding: EdgeInsets.all(SizeConfig.width(2.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                SizedBox(height: SizeConfig.height(1.5)),
                _buildQuickUpdates(),
                SizedBox(height: SizeConfig.height(1.5)),
                buildAppointmentDisplay(appointmentProvider),
                SizedBox(height: SizeConfig.height(2)),
                _buildQuickLinks(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(AppointmentProvider appointmentProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderBackground(),
          Padding(
            padding: EdgeInsets.all(SizeConfig.width(2)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildUserInfo(),
                      SizedBox(height: SizeConfig.height(2)),
                      _buildQuickUpdates(),
                    ],
                  ),
                ),
                SizedBox(width: SizeConfig.width(2)),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      buildAppointmentDisplay(appointmentProvider),
                      SizedBox(height: SizeConfig.height(2)),
                      _buildQuickLinks(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AppointmentProvider appointmentProvider) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildHeaderBackground(),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.width(1.5)),
            child: Column(
              children: [
                _buildUserInfo(),
                SizedBox(height: SizeConfig.height(2)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildQuickUpdates(),
                    ),
                    SizedBox(width: SizeConfig.width(2)),
                    Expanded(
                      child: buildAppointmentDisplay(appointmentProvider),
                    ),
                    SizedBox(width: SizeConfig.width(2)),
                    Expanded(
                      child: _buildQuickLinks(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods to handle appointment date widgets
  Widget buildAppointmentDate(DateTime date, {Size size = const Size(50, 50)}) {
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat("d").format(date),
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        ],
      ),
    );
  }

  Widget buildAppointmentDisplay(AppointmentProvider appointmentProvider) {
    if (latestAppointment == null) {
      return const Center(child: Text('No upcoming appointments'));
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/navBar', arguments: 1);
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Pending Appointment"),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Smaller size for "days 2"
                  buildAppointmentDate(
                    latestAppointment!.appointmentDate
                        .subtract(const Duration(days: 2)),
                    size: const Size(40, 40), // Adjust the size as needed
                  ),

                  // Larger size for "days 1"
                  buildAppointmentDate(
                    latestAppointment!.appointmentDate
                        .subtract(const Duration(days: 1)),
                    size: const Size(60, 60), // Adjust the size as needed
                  ),

                  // Highlighted appointment date (default size)
                  buildHighlightedAppointmentDate(
                    latestAppointment!.appointmentDate,
                  ),

                  // Larger size for "day 1"
                  buildAppointmentDate(
                    latestAppointment!.appointmentDate
                        .add(const Duration(days: 1)),
                    size: const Size(60, 60), // Adjust the size as needed
                  ),

                  // Smaller size for "days 2"
                  buildAppointmentDate(
                    latestAppointment!.appointmentDate
                        .add(const Duration(days: 2)),
                    size: const Size(40, 40), // Adjust the size as needed
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.height(3)),
            ],
          ),
        ),
      );
    }
  }

  Widget buildHighlightedAppointmentDate(DateTime date) {
    return Container(
      height: 120,
      width: 95,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat("EEE").format(date),
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          Text(
            DateFormat("d").format(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Colors.white,
            ),
          ),
          Text(
            DateFormat("MMMM").format(date),
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: ResponsiveWidget.isMobile(context) ? 250 : double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: ResponsiveWidget.isMobile(context)
            ? BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : null,
      ),
      child: CustomPaint(
        painter: CirclePainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logged in as:',
            style: TextStyle(
                fontSize: SizeConfig.text(5.5),
                color: Theme.of(context).colorScheme.tertiary)),
        FutureBuilder<Map<String, dynamic>?>(
          future: _authService.fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitRipple(
                color: Theme.of(context).colorScheme.primary,
                size: SizeConfig.width(5),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final userData = snapshot.data!;
              final String name = userData['Name'] ?? "No Name";

              return Text(
                '$name ',
                style: TextStyle(
                  fontSize: SizeConfig.text(9),
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return const Text('No user data found.');
            }
          },
        ),
      ],
    );
  }

  Widget _buildQuickUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Updates",
          style: TextStyle(
            fontSize: SizeConfig.text(4),
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        SizedBox(height: SizeConfig.height(4)),
        const UpdateSlider(),
      ],
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      height: ResponsiveWidget.isMobile(context) ? 350 : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      child: Column(
        children: [
          SizedBox(height: SizeConfig.height(1)),
          Text(
            "Quick Links",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.text(4),
            ),
          ),
          SizedBox(height: SizeConfig.height(1)),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/CUT-Logo.png")),
                  title: Text(
                    'Wellness Centre',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.text(4)),
                  ),
                  subtitle: Text(
                    'Student life wellness',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  onTap: () async {
                    await launchUrl(Uri.parse(
                        'https://www.cut.ac.za/student-life-wellness'));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/CUT-Logo.png")),
                  title: Text(
                    'CUT',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.text(4)),
                  ),
                  subtitle: Text(
                    'Central University of Technology, Free State',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  onTap: () async {
                    await launchUrl(Uri.parse('https://www.cut.ac.za/'));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/CUT-Logo.png")),
                  title: Text(
                    'CUT Self Help iEnabler',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.text(4)),
                  ),
                  subtitle: Text(
                    'Self Help iEnabler Student Portal',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  onTap: () async {
                    await launchUrl(Uri.parse(
                        'https://enroll.cut.ac.za/pls/prodi41/w99pkg.mi_login'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Large light yellow circle
    paint.color = Colors.orange.shade300;
    canvas.drawCircle(
      Offset(size.width - 80, size.height * 0.2),
      size.width * 0.3,
      paint,
    );

    // Medium coral circle
    paint.color = const Color.fromARGB(255, 250, 148, 100).withOpacity(0.8);
    canvas.drawCircle(
      Offset(size.width - 130, size.height * 0.60),
      size.width * 0.13,
      paint,
    );

    // Small orange circle
    paint.color = Colors.deepOrange.withOpacity(0.8);
    canvas.drawCircle(
      Offset(size.width - 175, size.height * 0.45),
      size.width * 0.10,
      paint,
    );

    // Smallest orange circle
    paint.color = const Color.fromARGB(255, 223, 82, 39);
    canvas.drawCircle(
      Offset(size.width - 180, size.height * 0.57),
      size.width * 0.04,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
