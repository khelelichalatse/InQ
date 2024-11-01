import 'package:flutter/material.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/views/Authentication/change_password.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  Future<void> signIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState?.validate() ?? false) {
      Map<String, String?> result = await _auth.loginUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _emailError = result["emailError"];
        _passwordError = result["passwordError"];
      });

      if (result["status"] == "success") {
        Map<String, dynamic>? userDetails = await _auth.fetchUserData();
        if (userDetails.isNotEmpty) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch user details.")),
          );
        }
      } else if (result["generalError"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["generalError"]!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    return _buildForm();
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(70),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(40),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: SizeConfig.height(2)),
            Center(
              child: Text(
                "InQ",
                style: TextStyle(
                  fontSize: SizeConfig.text(12),
                  color: Colors.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.height(2)),
            Text(
              "Please login to continue",
              style: TextStyle(
                fontSize: SizeConfig.text(4),
                color: Colors.black,
                height: 1,
              ),
            ),
            SizedBox(height: SizeConfig.height(2)),
            _buildTextField(
              controller: _emailController,
              hintText: "Email/Username",
              errorText: _emailError,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig.height(2)),
            _buildTextField(
              controller: _passwordController,
              hintText: "Password",
              errorText: _passwordError,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig.height(3)),
            _buildLoginButton(),
            SizedBox(height: SizeConfig.height(1)),
            _buildForgotPasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        hintStyle: TextStyle(fontSize: SizeConfig.text(4), color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.width(6)),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        fillColor: Colors.orange.shade700,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width(4),
          vertical: SizeConfig.height(1.5),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildLoginButton() {
    return InkWell(
      onTap: signIn,
      child: Container(
        height: SizeConfig.height(5.5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(SizeConfig.width(5))),
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
            "LOGIN",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.text(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EmailResetPasswordScreen()),
        );
      },
      child: Text(
        "FORGOT PASSWORD?",
        style: TextStyle(
          fontSize: SizeConfig.text(3),
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1,
        ),
      ),
    );
  }

  // ... existing methods (signIn, dispose) ...
}

//_______________________________________________ LOGIN OPTIONS____________________________________________________

class LoginOptions extends StatelessWidget {
  const LoginOptions({super.key});

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
          'Existing user?',
          style: TextStyle(
            fontSize: SizeConfig.text(4),
          ),
        ),
        SizedBox(
          height: SizeConfig.height(2),
        ),
        Container(
          height: SizeConfig.height(6),
          decoration: BoxDecoration(
            color: Colors.black,
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
              "LOGIN",
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
