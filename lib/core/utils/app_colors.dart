import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color accentColor = Color(0xFF5098E6);
  static const Color textColor = Colors.white;
  static const Color subtitleColor = Colors.white70;

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A90E2),
      Color(0xFF5C9CE6),
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF081120),
      Color(0xFF12263F),
    ],
  );

  static LinearGradient backgroundGradientFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkBackgroundGradient
        : lightBackgroundGradient;
  }
}