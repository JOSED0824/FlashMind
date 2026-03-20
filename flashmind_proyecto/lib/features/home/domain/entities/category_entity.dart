import 'package:equatable/equatable.dart';
import '../../../../core/theme/app_gradients.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int iconCodePoint;
  final int totalTopics;
  final CategoryGradientType gradientType;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.totalTopics,
    required this.gradientType,
  });

  @override
  List<Object?> get props => [id, name, iconCodePoint, totalTopics, gradientType];
}
