import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade200,
      primary: Colors.orange,
      secondary: Colors.grey.shade200,
      tertiary: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.grey.shade100,
      onTertiary: Colors.grey[350]),
);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        surface: Colors.grey.shade800,
        primary: Colors.orange,
        secondary: Colors.grey.shade800,
        tertiary: Colors.grey.shade100,
        onPrimary: Colors.black,
        onSecondary: Colors.grey.shade600,
        onTertiary: Colors.grey[650]));
