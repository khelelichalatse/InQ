import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:inq_app/nav_bar.dart';
import 'package:inq_app/views/Authentication/login_signup.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                        return SpinKitRipple(
                      color: Colors.orange,
                    );
                  } else if (snapshot.hasData) {
                    Timer(const Duration(milliseconds: 2500), () {
                      Get.to(() => const NavBar());
                    });
                    return const SizedBox(
                      height: 150,
                    );
                  } else {
                    Timer(const Duration(milliseconds: 2500), () {
                      Get.to(() => const LoginScreenHome());
                    });
                    return const SizedBox(
                      height: 150,
                    );
                  }
                },
              ),
              const SizedBox(
                height: 150,
              ),
              Image.asset(
                'assets/1722348408675.png',
                height: 150,
              ),
              const Text(
                'WELCOME TO inQ!',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 200,
              ),
              const Text(
                'Powered by',
                style: TextStyle(color: Colors.black),
              ),
              Image.asset(
                "assets/M4NSoftwares.png",
                height: 50,
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
