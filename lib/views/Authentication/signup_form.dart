import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/nav_bar.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/views/Authentication/login_signup.dart';
import 'package:inq_app/views/Authentication/otp_verification_screen.dart';
import 'package:inq_app/widgets/Auth_TextFields.dart';
import 'package:inq_app/widgets/phone_text_field.dart';
import 'package:inq_app/services/twilio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _twilioService = TwilioServiceOTP();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isVisible = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _studentIdController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(
              child: SpinKitFadingCircle(
                color: Colors.orange,
                size: 50,
              ),
            );
          },
        );

        // Step 1: Check if email exists in Firestore
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .doc('Students')
            .collection('CUT')
            .where('Email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        if (userQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'An account with this email already exists. Please use a different email or try logging in.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Format phone number to ensure it's in international format
        String formattedPhone = _phoneNumberController.text.trim();
        if (!formattedPhone.startsWith('+')) {
          formattedPhone =
              '+27${formattedPhone.startsWith('0') ? formattedPhone.substring(1) : formattedPhone}';
        }

        // Show loading for SMS sending
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(
              child: SpinKitFadingCircle(
                color: Colors.orange,
                size: 50,
              ),
            );
          },
        );

        // Step 2: Send verification code
        bool codeSent =
            await _twilioService.sendVerificationCode(formattedPhone);

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        if (!codeSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to send verification code. Please check your phone number.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Step 3: Show OTP verification screen
        final bool? verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: formattedPhone,
              onVerificationSuccess: () {
                Navigator.pop(context, true);
              },
            ),
          ),
        );

        if (verified != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verification failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading for account creation
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(
              child: SpinKitFadingCircle(
                color: Colors.orange,
                size: 50,
              ),
            );
          },
        );

        // Step 4: Create user account
        final user = await _auth.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null) {
          await _auth.storePatientDetails(
            user.uid,
            _nameController.text.trim(),
            _surnameController.text.trim(),
            _studentIdController.text.trim(),
            _emailController.text.trim(),
            formattedPhone, // Use formatted phone number
            _passwordController.text.trim(),
          );

          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Navigate to NavBar
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NavBar()),
          );
        }
      } catch (ex) {
        // Ensure loading dialog is closed
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        String errorMessage = 'An unexpected error occurred';
        if (ex is FirebaseAuthException) {
          switch (ex.code) {
            case 'invalid-email':
              errorMessage = 'The email address is invalid.';
              break;
            case 'invalid-phone-number':
              errorMessage = 'The provided phone number is invalid.';
              break;
            default:
              errorMessage = ex.message ?? errorMessage;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          // Make padding responsive
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Make image responsive
                Image.asset(
                  "assets/1722348408675.png",
                  height: size.height * 0.12,
                ),

                // Adjust text sizes based on screen size
                Text(
                  "Welcome to inQ",
                  style: TextStyle(fontSize: size.width * 0.045),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  "Please register below to continue",
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
                SizedBox(height: size.height * 0.02),

                // Using the extracted AuthTextFields widget
                NameTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  hintText: 'Name',
                  validate1: 'Please enter your name',
                ),
                SizedBox(height: size.height * 0.02),

                NameTextField(
                  controller: _surnameController,
                  labelText: 'Surname',
                  hintText: 'Surname',
                  validate1: 'Please enter your surname',
                ),
                SizedBox(height: size.height * 0.02),

                AuthTextFields(
                  controller: _studentIdController,
                  labelText: 'Student Number',
                  keyboardType: TextInputType.number,
                  hintText: 'Student Number',
                  validate1: 'Please enter your Student Number',
                  validate2: (value) {
                    if (value!.length != 9) {
                      return "Student number must be exactly 9 digits long";
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return "Student number must contain only numbers";
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),

                PhoneTextField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                  hintText: 'Phone Number',
                  validate1: 'Please enter your phone number',
                ),
                SizedBox(height: size.height * 0.02),

                AuthTextFields(
                  controller: _emailController,
                  labelText: 'Student Email',
                  hintText: 'Student Email',
                  validate1: 'Please enter your email',
                  validate2: (value) {
                    if (!RegExp(r"^[a-zA-Z0-9]+@stud\.cut\.ac\.za$")
                        .hasMatch(value!)) {
                      return 'Email must be in the format of studentID@stud.cut.ac.za';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: size.height * 0.02),

                AuthTextFields(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Password',
                  validate1: 'Password must be at least 8 characters long',
                  validate2: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!RegExp(r"[a-z]").hasMatch(value)) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!RegExp(r"[A-Z]").hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!RegExp(r"[0-9]").hasMatch(value)) {
                      return 'Password must contain at least one number';
                    }
                    if (!RegExp(r"[^a-zA-Z0-9]").hasMatch(value)) {
                      return 'Password must contain at least one special character';
                    }
                    return null;
                  },
                  obscureText: isVisible,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  isVisible: isVisible,
                ),
                SizedBox(height: size.height * 0.02),

                AuthTextFields(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Confirm Password',
                  validate1: 'Passwords do not match',
                  validate2: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: isVisible,
                  isPassword: true,
                  onToggleVisibility: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  isVisible: isVisible,
                ),
                SizedBox(height: size.height * 0.02),

                // Signup Button
                InkWell(
                  onTap: signUp,
                  child: Container(
                    height: size.height * 0.06,
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        border: Border.all(color: Colors.grey.shade700),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: const Offset(0, 3))
                        ]),
                    child: const Center(
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreenHome()));
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color.fromRGBO(255, 151, 76, 50)),
                      ))
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
