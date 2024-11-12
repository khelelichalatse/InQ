import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:inq_app/views/Authentication/login_signup.dart';
import 'package:lottie/lottie.dart';

class EmailResetPasswordScreen extends StatefulWidget {
  const EmailResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _EmailResetPasswordScreenState createState() =>
      _EmailResetPasswordScreenState();
}

class _EmailResetPasswordScreenState extends State<EmailResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = AuthService();
  late final AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();

        // Validate student email format
        if (!RegExp(r"^[a-zA-Z0-9]+@stud\.cut\.ac\.za$").hasMatch(email)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid student email address'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check if email exists in Firebase
        bool emailExists = await _auth.checkEmailExistsInFirestore(email);
        if (!emailExists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Email not found. Please check your email or sign up.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Send password reset email
        await _auth.sendPasswordResetEmail(email);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Navigate back to login page after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreenHome()),
            );
          }
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/resetPassword.json',
              height: SizeConfig.height(20),
              fit: BoxFit.contain,
              controller: _animationController,
              repeat: true,
              onLoaded: (composition) {
                _animationController.duration = composition.duration * 5;
                _animationController.repeat();
              },
            ),
            SizedBox(height: SizeConfig.height(2)),
            Text(
              'Reset Your Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.text(6),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.height(2)),
            Text(
              'Enter your student email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.text(3.5),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: SizeConfig.height(3)),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Student Email',
                hintText: 'studentnumber@stud.cut.ac.za',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.width(2)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.width(4),
                  vertical: SizeConfig.height(2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig.height(3)),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.height(2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.width(2)),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: SpinKitCircle(
                        color: Colors.orange,
                      ),
                    )
                  : Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: SizeConfig.text(4),
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width(5)),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(60),
        child: _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(40),
        child: _buildMobileLayout(),
      ),
    );
  }
}
