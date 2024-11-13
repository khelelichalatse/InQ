// A widget that displays a loading animation using flutter_spinkit
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    // Displays a centered double bounce animation in orange
    return const Center(
        child: SpinKitDoubleBounce(
      color: Colors.orange,
      duration: Duration(seconds: 4),
      size: 60.0,
    ));
  }
}
