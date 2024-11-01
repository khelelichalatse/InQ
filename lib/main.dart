import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:inq_app/Theme/theme.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:inq_app/provider/User_provider.dart';
import 'package:inq_app/provider/Appointment_provider.dart';
import 'package:inq_app/services/firebase_firestore_service.dart';
import 'package:inq_app/services/firebase_messaging_service.dart';
import 'package:inq_app/views/Authentication/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:inq_app/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';


const String DEFAULT_THEME_MODE = 'system';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeServices();
    final String themeMode = await loadThemeMode();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppointmentProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MyApp(themeMode: themeMode),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    // Handle initialization error (e.g., show an error screen)
  }
}

Future<void> initializeServices() async {
  await Firebase.initializeApp();
  
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await notificationService.initFirebaseMessaging();

  final availabilityService = AvailabilityService();
  await availabilityService.initializeBusinessDaysForYear();
}

Future<String> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('themeMode') ?? DEFAULT_THEME_MODE;
}

class MyApp extends StatelessWidget {
  final String themeMode;

  const MyApp({Key? key, required this.themeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const SplashView(),
      routes: {
        '/navBar': (context) => const NavBar(),
      },
      themeMode: _getThemeMode(),
    );
  }

  ThemeMode _getThemeMode() {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
