import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_progress_entity.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 1)
class ProgressModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  int totalPoints;

  @HiveField(2)
  int totalSessions;

  @HiveField(3)
  int currentStreak;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  DateTime? lastSessionDate;

  @HiveField(6)
  List<String> completedTopicIds;

  ProgressModel({
    required this.userId,
    required this.totalPoints,
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    required this.completedTopicIds,
  });

  factory ProgressModel.empty(String userId) => ProgressModel(
        userId: userId,
        totalPoints: 0,
        totalSessions: 0,
        currentStreak: 0,
        longestStreak: 0,
        completedTopicIds: [],
      );

  UserProgressEntity toEntity() => UserProgressEntity(
        userId: userId,
        totalPoints: totalPoints,
        totalSessions: totalSessions,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastSessionDate: lastSessionDate,
        completedTopicIds: completedTopicIds,
      );

  void updateFromEntity(UserProgressEntity entity) {
    totalPoints = entity.totalPoints;
    totalSessions = entity.totalSessions;
    currentStreak = entity.currentStreak;
    longestStreak = entity.longestStreak;
    lastSessionDate = entity.lastSessionDate;
    completedTopicIds = entity.completedTopicIds;
  }
}
