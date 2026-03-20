import 'package:equatable/equatable.dart';
import '../../../results/domain/entities/achievement_entity.dart';
import '../../../session/domain/entities/session_result_entity.dart';

sealed class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

class ResultsLoading extends ResultsState {
  const ResultsLoading();
}

class ResultsLoaded extends ResultsState {
  final SessionResultEntity result;
  final List<AchievementEntity> achievements;

  const ResultsLoaded({required this.result, required this.achievements});

  @override
  List<Object?> get props => [result, achievements];
}

class ResultsError extends ResultsState {
  final String message;
  const ResultsError(this.message);

  @override
  List<Object?> get props => [message];
}
