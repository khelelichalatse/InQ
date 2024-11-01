import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/views/Authentication/login_.dart';
import 'package:inq_app/widgets/profile_page_textbox.dart';
import 'package:inq_app/services/twilio_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance
      .collection('Users')
      .doc('Students')
      .collection('CUT');
  final AuthService authService = AuthService();
  String? _newPhoneNumber;
  String? _otpCode;
  final TwilioServiceOTP _twilioService = TwilioServiceOTP();
  Map<String, dynamic>? userData;

  Future<void> editField(String field) async {
    String newValue = "";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: Colors.grey[900],
        title: Text(
          "Edit your $field",
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (newValue.trim().isNotEmpty) {
      await userCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  Future<void> _deleteAccount() async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                style: TextStyle(color: Colors.red),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: SpinKitRipple(color: Colors.orange, size: 60),
          ),
        );

        await userCollection.doc(currentUser.uid).delete();

        await currentUser.delete();

        Navigator.pop(context);

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        }
      } catch (e) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> editPhoneNumber() async {
    String? currentPhone = userData?['Phone Number'];
    final phoneController = TextEditingController();

    // First Dialog: Enter new phone number
    bool? shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current number: $currentPhone',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              child: IntlPhoneField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'New Phone Number',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                ),
                initialCountryCode: 'ZA', // Change this to your default country
                onChanged: (phone) {
                  _newPhoneNumber = phone.completeNumber;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text(
              'Send OTP',
              style: TextStyle(color: Colors.orange),
            ),
            onPressed: () {
              if (_newPhoneNumber != null && _newPhoneNumber!.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid phone number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );

    // Second Dialog: Enter OTP (shown after phone number is validated)
    if (shouldProceed == true && _newPhoneNumber != null) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: SpinKitRipple(color: Colors.orange, size: 60),
          ),
        );

        // Send OTP
        bool otpSent =
            await _twilioService.sendVerificationCode(_newPhoneNumber!);

        // Hide loading indicator
        Navigator.pop(context);

        if (!otpSent) {
          throw 'Failed to send OTP';
        }

        // Show OTP input dialog
        bool? verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Verify Phone Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the code sent to $_newPhoneNumber',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  onChanged: (value) => _otpCode = value,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Colors.orange),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (verified == true && _otpCode != null) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: SpinKitRipple(color: Colors.orange, size: 60),
            ),
          );

          // Verify OTP
          bool isVerified =
              await _twilioService.verifyCode(_newPhoneNumber!, _otpCode!);

          if (!isVerified) {
            throw 'Invalid OTP code';
          }

          // Update phone number in Firestore
          await userCollection.doc(currentUser.uid).update({
            'Phone Number': _newPhoneNumber,
          });

          // Hide loading indicator
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator if showing
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for contrast
      appBar: AppBar(
        elevation: 0, // Remove shadow
        title: const Text(
          'Update Profile',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc('Students')
            .collection('CUT')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            return ListView(
              children: [
                // Profile Header Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            (userData?['Name']?.toString() ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData?['Email']?.toString() ?? 'Email not available',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Personal Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              color: Colors.orange),
                          const SizedBox(width: 10),
                          Text(
                            'Personal Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  MyTextBox(
                                    text: userData?['Name']?.toString() ?? 'Not set',
                                    sectionName: 'Name',
                                    onPressed: () => editField('Name'),
                                  ),
                                  MyTextBox(
                                    text: userData?['Surname']?.toString() ?? 'Not set',
                                    sectionName: 'Surname',
                                    onPressed: () => editField('Surname'),
                                  ),
                                  MyTextBox(
                                    text: userData?['StudentID']?.toString() ?? 'Not set',
                                    sectionName: 'Student Number',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                              'You cannot edit your Student Number.Contact the CUT admin for assistance.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                  MyTextBox(
                                    text: userData?['Phone Number']?.toString() ?? 'Not set',
                                    sectionName: 'Phone Number',
                                    onPressed: editPhoneNumber,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Danger Zone',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 28,
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      onTap: _deleteAccount,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(
            child: SpinKitRipple(color: Colors.orange, size: 60),
          );
        },
      ),
    );
  }
}
