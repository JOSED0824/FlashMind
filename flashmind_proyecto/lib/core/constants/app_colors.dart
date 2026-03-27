import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF07131F);
  static const Color surface = Color(0xFF102338);
  static const Color surface2 = Color(0xFF16314D);
  static const Color border = Color(0x22D7E8FF);

  // Text
  static const Color textPrimary = Color(0xFFF3F8FF);
  static const Color textSecondary = Color(0xFFADC3DC);
  static const Color textDisabled = Color(0xFF6E8FAF);

  // Feedback
  static const Color correct = Color(0xFF3AD29F);
  static const Color incorrect = Color(0xFFFF6B81);
  static const Color warning = Color(0xFFFFB15C);

  // Accent (Ocean)
  static const Color accentStart = Color(0xFF00B8D9);
  static const Color accentEnd = Color(0xFF3AE6C1);

  // Category: History (orange)
  static const Color historyStart = Color(0xFFF97316);
  static const Color historyEnd = Color(0xFFF7B267);

  // Category: Science (blue)
  static const Color scienceStart = Color(0xFF2D9CFF);
  static const Color scienceEnd = Color(0xFF68D4FF);

  // Category: Languages (green)
  static const Color languagesStart = Color(0xFF1FC28A);
  static const Color languagesEnd = Color(0xFF5FF2B7);

  // Category: Technology (cyan)
  static const Color techStart = Color(0xFF00C2C7);
  static const Color techEnd = Color(0xFF3CE9DC);
}
