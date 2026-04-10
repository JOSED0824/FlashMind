import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CategoryGradientType { history, science, languages, technology }

abstract final class AppGradients {
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accentStart, AppColors.accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient history = LinearGradient(
    colors: [AppColors.historyStart, AppColors.historyEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient science = LinearGradient(
    colors: [AppColors.scienceStart, AppColors.scienceEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient languages = LinearGradient(
    colors: [AppColors.languagesStart, AppColors.languagesEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient technology = LinearGradient(
    colors: [AppColors.techStart, AppColors.techEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashBackground = LinearGradient(
    colors: [Color(0xFF04101A), Color(0xFF0A2234), Color(0xFF12344C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient forCategory(CategoryGradientType type) {
    switch (type) {
      case CategoryGradientType.history:
        return history;
      case CategoryGradientType.science:
        return science;
      case CategoryGradientType.languages:
        return languages;
      case CategoryGradientType.technology:
        return technology;
    }
  }

  static Color shadowColorForCategory(CategoryGradientType type) {
    switch (type) {
      case CategoryGradientType.history:
        return AppColors.historyStart.withValues(alpha: 0.4);
      case CategoryGradientType.science:
        return AppColors.scienceStart.withValues(alpha: 0.4);
      case CategoryGradientType.languages:
        return AppColors.languagesStart.withValues(alpha: 0.4);
      case CategoryGradientType.technology:
        return AppColors.techStart.withValues(alpha: 0.4);
    }
  }
}
