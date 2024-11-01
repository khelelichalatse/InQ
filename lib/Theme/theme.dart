import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade200,
      primary: Colors.orange,
      secondary: Colors.grey.shade200,
      tertiary: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.grey.shade200),
);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade800,
      primary: Colors.orange,
      secondary: Colors.grey.shade800,
      tertiary: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.grey.shade600,
    ));
