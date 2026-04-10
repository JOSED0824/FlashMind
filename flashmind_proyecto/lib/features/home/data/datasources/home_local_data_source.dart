import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/entities/category_entity.dart';
import '../models/progress_model.dart';

abstract interface class HomeLocalDataSource {
  Future<List<CategoryEntity>> getCategories();
  Future<ProgressModel> getUserProgress(String userId);
  Future<void> saveUserProgress(ProgressModel progress);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final Box<ProgressModel> _progressBox;

  HomeLocalDataSourceImpl(this._progressBox);

  static const _categories = [
    CategoryEntity(
      id: 'history',
      name: 'Historia',
      description: 'Civilizaciones, eventos y personajes que cambiaron el mundo.',
      iconCodePoint: 0xe54e, // Icons.history_edu_rounded
      totalTopics: 4,
      estimatedMinutes: 7,
      difficultyLevel: 'Principiante',
      gradientType: CategoryGradientType.history,
    ),
    CategoryEntity(
      id: 'science',
      name: 'Ciencia',
      description: 'Física, química y biología explicadas en pequeñas dosis.',
      iconCodePoint: 0xe1b1, // Icons.science_rounded
      totalTopics: 4,
      estimatedMinutes: 10,
      difficultyLevel: 'Intermedio',
      gradientType: CategoryGradientType.science,
    ),
    CategoryEntity(
      id: 'languages',
      name: 'Idiomas',
      description: 'Vocabulario y frases clave de distintos idiomas del mundo.',
      iconCodePoint: 0xe894, // Icons.language_rounded
      totalTopics: 4,
      estimatedMinutes: 7,
      difficultyLevel: 'Principiante',
      gradientType: CategoryGradientType.languages,
    ),
    CategoryEntity(
      id: 'technology',
      name: 'Tecnología',
      description: 'Conceptos de programación, IA y tendencias digitales.',
      iconCodePoint: 0xe1d9, // Icons.memory_rounded
      totalTopics: 4,
      estimatedMinutes: 12,
      difficultyLevel: 'Avanzado',
      gradientType: CategoryGradientType.technology,
    ),
  ];

  @override
  Future<List<CategoryEntity>> getCategories() async => _categories;

  @override
  Future<ProgressModel> getUserProgress(String userId) async {
    var progress = _progressBox.get(userId);
    if (progress == null) {
      progress = ProgressModel.empty(userId);
      await _progressBox.put(userId, progress);
    }
    return progress;
  }

  @override
  Future<void> saveUserProgress(ProgressModel progress) async {
    await _progressBox.put(progress.userId, progress);
  }
}

// Extension to create IconData from codePoint
extension IconDataFromCodePoint on int {
  IconData get asIcon => IconData(this, fontFamily: 'MaterialIcons');
}
