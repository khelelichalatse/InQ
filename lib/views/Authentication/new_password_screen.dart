import 'package:flutter/material.dart';
import 'package:inq_app/services/firebase_auth_service.dart';
import 'package:inq_app/widgets/my_buttons.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  
  const NewPasswordScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = AuthService();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set New Password',
            style: TextStyle(
              fontSize: SizeConfig.text(4),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: SizeConfig.height(3)),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: SizeConfig.height(2)),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: SizeConfig.height(3)),
          MyPositiveButton(
            text: 'Update Password',
            onTap: _updatePassword,
          ),
        ],
      ),
    );
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.updatePassword(
          widget.email,
          _passwordController.text,
        );
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.width(4)),
          child: _buildForm(),
        ),
      ),
    );
  }

  // Add responsive layout methods similar to ResetPasswordScreen
  // ... rest of the UI code
} 