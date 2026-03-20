import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF09090F);
  static const Color surface = Color(0xFF12121F);
  static const Color surface2 = Color(0xFF1A1A2E);
  static const Color border = Color(0x12FFFFFF); // rgba(255,255,255,0.07)

  // Text
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textDisabled = Color(0xFF6B6B9A);

  // Feedback
  static const Color correct = Color(0xFF11C97A);
  static const Color incorrect = Color(0xFFFF4D6D);
  static const Color warning = Color(0xFFFFA94D);

  // Accent (Tech / Purple)
  static const Color accentStart = Color(0xFF7C5CFC);
  static const Color accentEnd = Color(0xFFC56CFC);

  // Category: History (orange)
  static const Color historyStart = Color(0xFFFF6B2B);
  static const Color historyEnd = Color(0xFFFF9F43);

  // Category: Science (blue)
  static const Color scienceStart = Color(0xFF2B7CFF);
  static const Color scienceEnd = Color(0xFF43C6FF);

  // Category: Languages (green)
  static const Color languagesStart = Color(0xFF11C97A);
  static const Color languagesEnd = Color(0xFF43FFB4);

  // Category: Technology (purple)
  static const Color techStart = Color(0xFF7C5CFC);
  static const Color techEnd = Color(0xFFC56CFC);
}
