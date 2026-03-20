import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int iconCodePoint;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCodePoint,
    required this.isUnlocked,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, title, description, iconCodePoint, isUnlocked, unlockedAt];
}
