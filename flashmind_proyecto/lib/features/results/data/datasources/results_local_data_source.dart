import '../../domain/entities/achievement_entity.dart';
import '../../../session/domain/entities/session_result_entity.dart';

abstract interface class ResultsLocalDataSource {
  Future<List<AchievementEntity>> getAchievementsForResult(SessionResultEntity result);
}

class ResultsLocalDataSourceImpl implements ResultsLocalDataSource {
  @override
  Future<List<AchievementEntity>> getAchievementsForResult(SessionResultEntity result) async {
    final achievements = <AchievementEntity>[];

    if (result.accuracy >= 1.0) {
      achievements.add(const AchievementEntity(
        id: 'perfect_score',
        title: '¡Puntuación perfecta!',
        description: 'Respondiste todas las preguntas correctamente',
        iconCodePoint: 0xe001, // Icons.emoji_events_rounded
        isUnlocked: true,
      ));
    }

    if (result.accuracy >= 0.8) {
      achievements.add(const AchievementEntity(
        id: 'expert',
        title: 'Experto',
        description: 'Más del 80% de respuestas correctas',
        iconCodePoint: 0xe8af, // Icons.military_tech_rounded
        isUnlocked: true,
      ));
    }

    if (result.timeTakenSeconds < 120) {
      achievements.add(const AchievementEntity(
        id: 'speed_learner',
        title: 'Aprendiz veloz',
        description: 'Completaste la sesión en menos de 2 minutos',
        iconCodePoint: 0xe425, // Icons.flash_on_rounded
        isUnlocked: true,
      ));
    }

    if (result.pointsEarned >= 50) {
      achievements.add(const AchievementEntity(
        id: 'point_collector',
        title: 'Coleccionista',
        description: 'Ganaste 50 o más puntos en una sesión',
        iconCodePoint: 0xe227, // Icons.star_rounded
        isUnlocked: true,
      ));
    }

    return achievements;
  }
}
