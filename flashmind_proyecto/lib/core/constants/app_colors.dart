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

  // Category: Mathematics (purple)
  static const Color mathStart = Color(0xFF7C3AED);
  static const Color mathEnd = Color(0xFFA78BFA);

  // Category: Art & Culture (rose)
  static const Color artStart = Color(0xFFEC4899);
  static const Color artEnd = Color(0xFFF9A8D4);

  // Category: Geography (emerald)
  static const Color geoStart = Color(0xFF059669);
  static const Color geoEnd = Color(0xFF6EE7B7);

  // Category: Philosophy (indigo)
  static const Color philStart = Color(0xFF4F46E5);
  static const Color philEnd = Color(0xFF818CF8);

  // Category: Economics (amber)
  static const Color econStart = Color(0xFFD97706);
  static const Color econEnd = Color(0xFFFCD34D);
}

/// Colores responsivos al tema — usar `context.ac.surface` etc.
extension AppColorsTheme on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get acBg      => _isDark ? const Color(0xFF07131F) : const Color(0xFFF0F7FF);
  Color get acBgMid   => _isDark ? const Color(0xFF0B2032) : const Color(0xFFE4F1FF);
  Color get acBgEnd   => _isDark ? const Color(0xFF102C42) : const Color(0xFFD5E9FF);
  Color get acSurface => _isDark ? AppColors.surface        : Colors.white;
  Color get acSurface2=> _isDark ? AppColors.surface2       : const Color(0xFFECF5FF);
  Color get acBorder  => _isDark ? AppColors.border         : const Color(0x22004466);
  Color get acText    => _isDark ? AppColors.textPrimary    : const Color(0xFF0D2137);
  Color get acTextSub => _isDark ? AppColors.textSecondary  : const Color(0xFF4A6D8C);
  Color get acNavBar  => _isDark ? AppColors.surface        : Colors.white;
}
