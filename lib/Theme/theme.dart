// Import material design library for theming
import 'package:flutter/material.dart';

// Light theme configuration for the application
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      // Background color for surfaces like cards
      surface: Colors.grey.shade200,
      // Primary brand color (orange)
      primary: Colors.orange,
      // Secondary color for less prominent elements
      secondary: Colors.grey.shade200,
      // Color for text and icons
      tertiary: Colors.black,
      // Text/icon color on primary color
      onPrimary: Colors.white,
      // Text/icon color on secondary color
      onSecondary: Colors.grey.shade100,
      // Text/icon color on tertiary color
      onTertiary: Colors.grey[350]),
);

// Dark theme configuration for the application
ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        // Dark mode surface color
        surface: Colors.grey.shade800,
        // Primary brand color remains orange
        primary: Colors.orange,
        // Darker secondary color for contrast
        secondary: Colors.grey.shade800,
        // Light color for text and icons
        tertiary: Colors.grey.shade100,
        // Dark text on primary color
        onPrimary: Colors.black,
        // Text color on secondary surfaces
        onSecondary: Colors.grey.shade600,
        // Text color on tertiary elements
        onTertiary: Colors.grey[650]));
