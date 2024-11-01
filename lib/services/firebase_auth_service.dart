import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inq_app/services/firebase_storage_service.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:email_otp/email_otp.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final EmailOTP emailOTP = EmailOTP();

  // Method to get the current user's ID
  String? getCurrentUserId() {
    User? user = _auth.currentUser; // Fetch current user from FirebaseAuth
    return user
        ?.uid; // Return the user ID if the user is logged in, otherwise return null
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  // Method to store patient details
  Future<void> storePatientDetails(
    String userId,
    String name,
    String surname,
    String studentId,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .doc(userId)
          .set({
        'Name': name,
        'Surname': surname,
        'StudentID': studentId,
        'Email': email,
        'Phone Number': phoneNumber,
        'Password': password,
      });
    } catch (ex) {
      log("Had trouble storing the user's data for: $studentId: $ex");
    }
  }


  // Fetch user details from Firestore
  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('Users')
            .doc('Students')
            .collection('CUT')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        } else {
          log('User not found');
        }
      }
      return {};
    } catch (ex) {
      log("Error fetching user data: $ex");
      return {};
    }
  }

  // Method to update profile photo URL
  Future<void> updateProfilePhoto(File image) async {
    try {
      // Upload image to Firebase Storage and get the download URL
      String downloadUrl =
          await FirebaseStorageService().uploadImageToStorage(image);

      // Ensure current user is available before proceeding
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in.");
      }

      // Update the Firestore document for the current user with the new image URL
      await _firestore.collection('Users')..doc('Students').collection('CUT').doc(currentUser.uid).update({
        'imageUrl': downloadUrl, // Update Firestore with new image URL
      });
    } catch (e) {
      print("Error updating profile photo: $e");
      throw Exception("Failed to update profile photo");
    }
  }

  // Optional: Define your method to upload the image to cloud storage and get the download URL
  // Method to upload an image to Firebase Storage and get its download URL
  Future<String> uploadImageToStorage(File image) async {
    try {
      // Generate a unique file name using the file name and current timestamp
      String fileName = basename(image.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fullFileName = "$fileName-$timestamp";

      // Create a reference to the location where the image will be stored
      Reference storageRef =
          _storage.ref().child('uploads/images/$fullFileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Failed to upload image to Firebase Storage");
    }
  }

  // Method to register a new user
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (ex) {
      log("Error creating user: $ex");
      throw ex;  // Re-throw the exception
    }
  }

  // Method to login an existing user
  Future<Map<String, String?>> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return {"status": "success"};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {"emailError": "No user found for that email."};
      } else if (e.code == 'wrong-password') {
        return {"passwordError": "Wrong password provided for that user."};
      } else if (e.code == 'invalid-email') {
        return {"emailError": "Invalid email address."};
      } else {
        return {"generalError": "An error occurred: ${e.message}"};
      }
    } catch (ex) {
      log("Error logging in: $ex");
      return {"generalError": "An unexpected error occurred."};
    }
  }

  // Logout user
  Future<void> signOut() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await setUserLoggedIn(user.uid, false);
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> isUserLoggedIn(String userId) async {
    DocumentSnapshot userDoc = await _firestore
        .collection('Users')
        .doc('Students')
        .collection('CUT')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return (userDoc.data() as Map<String, dynamic>)['isLoggedIn'] ?? false;
    }
    return false;
  }

  Future<void> setUserLoggedIn(String userId, bool isLoggedIn) async {
    await _firestore
        .collection('Users')
        .doc('Students')
        .collection('CUT')
        .doc(userId)
        .update({'isLoggedIn': isLoggedIn});
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'No user found with this email';
          case 'invalid-email':
            throw 'Invalid email address';
          default:
            throw 'Failed to send reset email: ${e.message}';
        }
      }
      throw 'Failed to send reset email';
    }
  }

  Future<void> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'expired-action-code':
            throw 'The reset link has expired';
          case 'invalid-action-code':
            throw 'Invalid reset link';
          case 'weak-password':
            throw 'Password is too weak';
          default:
            throw 'Failed to reset password: ${e.message}';
        }
      }
      throw 'Failed to reset password';
    }
  }

  Future<bool> sendPasswordResetOTP(String email) async {
    try {
      EmailOTP.config(
        appEmail: "support@InQ.com",
        appName: "InQ",
        //email: email,
        otpLength: 6,
        otpType: OTPType.numeric,
        expiry: 30000
      );

      EmailOTP.setTemplate(
        template: '''
        <div style="background-color: #f0f2f5; padding: 20px; font-family: Arial, sans-serif;">
          <div style="background-color: #ffffff; padding: 30px; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
            <h1 style="color: #FF8C00; text-align: center; margin-bottom: 20px;">{{appName}} Password Reset</h1>
            <p style="color: #333; font-size: 16px;">Hello,</p>
            <p style="color: #333; font-size: 16px;">You have requested to reset your password. Please use the following verification code:</p>
            <div style="background-color: #fff5e6; padding: 15px; border-radius: 8px; text-align: center; margin: 20px 0;">
              <span style="font-size: 24px; font-weight: bold; color: #FF8C00; letter-spacing: 3px;">{{otp}}</span>
            </div>
            <p style="color: #666; font-size: 14px;">This code will expire in 5 minutes.</p>
            <p style="color: #666; font-size: 14px;">If you didn't request this code, please ignore this email.</p>
            <hr style="border: 1px solid #eee; margin: 20px 0;">
            <p style="color: #888; font-size: 12px; text-align: center;">© 2024 INQ. All rights reserved.</p>
          </div>
        </div>
        '''
      );
      
      return EmailOTP.sendOTP(email: email);
    } catch (e) {
      log("Error sending OTP: $e");
      throw 'Failed to send verification code';
    }
  }

  Future<bool> verifyOTP(String otp) async {
    try {
      return EmailOTP.verifyOTP(otp: otp);
    } catch (e) {
      log("Error verifying OTP: $e");
      return false;
    }
  }
Future<bool> sendChangePasswordOTP(String email) async {
  try {
    EmailOTP.config(
      appEmail: "support@InQ.com",
      appName: "InQ",
      otpLength: 6,
      otpType: OTPType.numeric,
      expiry: 300000, // 5 minutes
    );

    EmailOTP.setTemplate(
      template: '''
      <div style="background-color: #f0f2f5; padding: 20px; font-family: Arial, sans-serif;">
        <div style="background-color: #ffffff; padding: 30px; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
          <h1 style="color: #FF8C00; text-align: center; margin-bottom: 20px;">{{appName}} Password Change Request</h1>
          <p style="color: #333; font-size: 16px;">Hello,</p>
          <p style="color: #333; font-size: 16px;">We received a request to change your password. Please use the following verification code:</p>
          <div style="background-color: #fff5e6; padding: 15px; border-radius: 8px; text-align: center; margin: 20px 0;">
            <span style="font-size: 24px; font-weight: bold; color: #FF8C00; letter-spacing: 3px;">{{otp}}</span>
          </div>
          <p style="color: #666; font-size: 14px;">This code will expire in 5 minutes.</p>
          <p style="color: #666; font-size: 14px;">If you didn't request this code, please ignore this email.</p>
          <hr style="border: 1px solid #eee; margin: 20px 0;">
          <p style="color: #888; font-size: 12px; text-align: center;">© 2024 INQ. All rights reserved.</p>
        </div>
      </div>
      '''
    );
    
    return EmailOTP.sendOTP(email: email);
  } catch (e) {
    log("Error sending change password OTP: $e");
    throw 'Failed to send verification code';
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    try {
      // Get user by email
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        throw 'No user found with this email';
      }

      // Update password
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw 'User not authenticated';
      }
    } catch (e) {
      log("Error updating password: $e");
      throw 'Failed to update password';
    }
  }

  Future<bool> checkEmailExistsInFirestore(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('Users')
          .doc('Students')
          .collection('CUT')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      log("Error checking if email exists in Firestore: $e");
      return false;
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      // Get the password reset code that was sent to email
      String code = await _auth.verifyPasswordResetCode(email);
      
      // Confirm the password reset
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      throw 'Failed to update password: ${e.toString()}';
    }
  }
}

