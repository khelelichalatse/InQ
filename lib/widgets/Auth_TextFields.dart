import 'package:flutter/material.dart';

import 'package:inq_app/functional_supports/responsive.dart';

class AuthTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String validate1;
  final bool obscureText;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;
  final bool isVisible;
  final String? Function(String?)? validate2;
  final TextInputType keyboardType;

  const AuthTextFields({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.validate1,
    this.obscureText = false,
    this.isPassword = false,
    this.onToggleVisibility,
    this.isVisible = false,
    this.validate2,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: SizeConfig.text(4.5),
          color: Colors.black,
        ),
        fillColor: Colors.grey.withOpacity(0.2),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.width(5)),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.width(5)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width(4),
          vertical: SizeConfig.height(2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: SizeConfig.width(5),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      style: TextStyle(fontSize: SizeConfig.text(4.5)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validate1;
        }
        if (validate2 != null) {
          return validate2!(value);
        }
        return null;
      },
    );
  }
}

class NameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String validate1;

  const NameTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.validate1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          fillColor: Colors.grey.withOpacity(0.2),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validate1;
          }
          return null;
        },
      ),
    );
  }
}
