import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String initialCountryCode;
  final Function(String)? onChanged;
  final String validate1;

  const PhoneTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.validate1,
    this.onChanged,
    this.initialCountryCode = 'ZA',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.height(1.5)),
      child: IntlPhoneField(
        controller: controller,
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
        ),
        initialCountryCode: initialCountryCode,
        onChanged: (phone) {
          if (onChanged != null) {
            onChanged!(phone.completeNumber);
          }
        },
        validator: (value) {
          if (value == null) {
            return validate1;
          }
          return null;
        },
      ),
    );
  }
}
