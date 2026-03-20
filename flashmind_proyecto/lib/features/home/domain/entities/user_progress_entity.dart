import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final String userId;
  final int totalPoints;
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSessionDate;
  final List<String> completedTopicIds;

  const UserProgressEntity({
    required this.userId,
    required this.totalPoints,
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    required this.completedTopicIds,
  });

  UserProgressEntity copyWith({
    int? totalPoints,
    int? totalSessions,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSessionDate,
    List<String>? completedTopicIds,
  }) {
    return UserProgressEntity(
      userId: userId,
      totalPoints: totalPoints ?? this.totalPoints,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalPoints,
        totalSessions,
        currentStreak,
        longestStreak,
        lastSessionDate,
        completedTopicIds,
      ];
}
