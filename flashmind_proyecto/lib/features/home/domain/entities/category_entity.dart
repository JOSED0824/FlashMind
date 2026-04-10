import 'package:equatable/equatable.dart';
import '../../../../core/theme/app_gradients.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final int totalTopics;
  final int estimatedMinutes;
  final String difficultyLevel;
  final CategoryGradientType gradientType;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.totalTopics,
    required this.estimatedMinutes,
    required this.difficultyLevel,
    required this.gradientType,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconCodePoint,
        totalTopics,
        estimatedMinutes,
        difficultyLevel,
        gradientType,
      ];
}
