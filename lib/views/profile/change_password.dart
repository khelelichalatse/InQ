import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:email_otp/email_otp.dart';

// Screen for handling password changes with email verification
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Firebase and service instances
  final _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isVerified = false;
  String? _otpCode;
  String? _newPassword;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _currentPassword;

  // Main method to handle verification and password change
  Future<void> _verifyAndChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      setState(() => _isLoading = true);
      
      if (!_isVerified) {
        // First step: Send OTP
        User? user = _auth.currentUser;
        if (user == null || user.email == null) throw 'User not found';
        
        bool otpSent = await _authService.sendChangePasswordOTP(user.email!);
        if (!otpSent) throw 'Failed to send verification code';
        
        // Show OTP input dialog
        String? enteredOTP = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Verify Your Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We sent a verification code to ${user.email}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  onChanged: (value) => _otpCode = value,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Verify', style: TextStyle(color: Colors.orange)),
                onPressed: () => Navigator.pop(context, _otpCode),
              ),
            ],
          ),
        );

        if (enteredOTP == null) return;

        // Verify OTP
        bool isVerified = EmailOTP.verifyOTP(otp: enteredOTP);
        if (!isVerified) throw 'Invalid verification code';

        setState(() => _isVerified = true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified! You can now set your new password.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Second step: Change password
        if (_newPassword == null) throw 'Please enter a new password';
        
        User? user = _auth.currentUser;
        if (user == null) throw 'User not found';
        
        // Add reauthentication before password update
        try {
          // Get user's email credentials first
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPassword!,
          );
          
          // Reauthenticate
          await user.reauthenticateWithCredential(credential);
          
          // Now update password
          await user.updatePassword(_newPassword!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context);
        } catch (e) {
          throw 'Please log in again before changing your password';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "assets/reset_password.png",
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  _isVerified 
                    ? "CREATE NEW PASSWORD"
                    : "VERIFY YOUR EMAIL",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _isVerified
                    ? "Please enter your new password below"
                    : "We'll send you a verification code to your email",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_isVerified)
                  Column(
                    children: [
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter current password' : null,
                        onChanged: (value) => _currentPassword = value,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Password must contain at least one lowercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                        onChanged: (value) => _newPassword = value,
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyAndChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isVerified ? 'Update Password' : 'Send Verification Code',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
