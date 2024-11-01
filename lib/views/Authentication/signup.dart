import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inq_app/views/Authentication/login_signup.dart';
import 'package:inq_app/views/Authentication/signup_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:inq_app/functional_supports/responsive.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithMicrosoft() async {
    try {
      final provider = OAuthProvider('microsoft.com');
      provider.setCustomParameters({
        'tenant': '118a732c-d88b-4351-945b-03cdc6c562f2',
        'prompt': 'select_account',
      });

      if (kIsWeb) {
        // Web platform
        final result = await _auth.signInWithPopup(provider);
        _handleAuthResult(result.user);
      } else {
        // Mobile platforms
        final result = await _auth.signInWithProvider(provider);
        _handleAuthResult(result.user);
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
      );
    }
  }

  void _handleAuthResult(User? user) {
    if (user != null) {
      print("Logged in as ${user.displayName}");
      // TODO: Navigate to the next screen or update UI
    } else {
      print("Login failed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ResponsiveWidget(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return _buildContent();
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(70),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(40),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "InQ",
            style: TextStyle(
              fontSize: SizeConfig.text(12),
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              height: 1,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.height(2)),
        Text(
          "Sign up with",
          style: TextStyle(
              fontSize: SizeConfig.text(4), color: Colors.orange, height: 2),
        ),
        // SizedBox(height: SizeConfig.height(2)),
        // _buildMicrosoftSignInButton(),
        // SizedBox(height: SizeConfig.height(1.5)),
        // _buildDivider(),
        SizedBox(height: SizeConfig.height(1.5)),
        _buildEmailSignUpButton(),
        SizedBox(height: SizeConfig.height(3)),
        _buildTermsText(),
        SizedBox(height: SizeConfig.height(2)),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildEmailSignUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      child: Container(
        height: SizeConfig.height(5.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(SizeConfig.width(5))),
          border: Border.all(color: Colors.grey.shade700),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, color: Colors.orange),
              SizedBox(width: SizeConfig.width(2)),
              Text(
                "EMAIL",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.text(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By creating an account you agree with our Terms of Service, Privacy Policy, and our default Notification Settings.',
      style: TextStyle(
        fontSize: SizeConfig.text(3),
        color: Colors.orange,
        height: 1,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(fontSize: SizeConfig.text(4)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreenHome()),
            );
          },
          child: Text(
            "Log in",
            style: TextStyle(
              decoration: TextDecoration.none,
              color: Colors.orange,
              fontSize: SizeConfig.text(4),
            ),
          ),
        )
      ],
    );
  }
}

//_______________________________________________ SIGNUP OPTIONS____________________________________________________

class SignUpOptions extends StatelessWidget {
  const SignUpOptions({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ResponsiveWidget(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(70),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(40),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(
            fontSize: SizeConfig.text(4),
            color: Colors.orange,
          ),
        ),
        SizedBox(
          height: SizeConfig.height(2),
        ),
        Container(
          height: SizeConfig.height(5.5),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius:
                BorderRadius.all(Radius.circular(SizeConfig.width(5))),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 4,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Center(
            child: Text(
              "SIGNUP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.text(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
