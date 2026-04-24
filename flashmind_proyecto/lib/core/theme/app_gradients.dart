import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CategoryGradientType { history, science, languages, technology, mathematics, art, geography, philosophy, economics }

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

  static const LinearGradient mathematics = LinearGradient(
    colors: [AppColors.mathStart, AppColors.mathEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient art = LinearGradient(
    colors: [AppColors.artStart, AppColors.artEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient geography = LinearGradient(
    colors: [AppColors.geoStart, AppColors.geoEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient philosophy = LinearGradient(
    colors: [AppColors.philStart, AppColors.philEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient economics = LinearGradient(
    colors: [AppColors.econStart, AppColors.econEnd],
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
      case CategoryGradientType.mathematics:
        return mathematics;
      case CategoryGradientType.art:
        return art;
      case CategoryGradientType.geography:
        return geography;
      case CategoryGradientType.philosophy:
        return philosophy;
      case CategoryGradientType.economics:
        return economics;
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
      case CategoryGradientType.mathematics:
        return AppColors.mathStart.withValues(alpha: 0.4);
      case CategoryGradientType.art:
        return AppColors.artStart.withValues(alpha: 0.4);
      case CategoryGradientType.geography:
        return AppColors.geoStart.withValues(alpha: 0.4);
      case CategoryGradientType.philosophy:
        return AppColors.philStart.withValues(alpha: 0.4);
      case CategoryGradientType.economics:
        return AppColors.econStart.withValues(alpha: 0.4);
    }
  }
}
