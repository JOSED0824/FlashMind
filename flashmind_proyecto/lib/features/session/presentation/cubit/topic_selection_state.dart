import 'package:equatable/equatable.dart';
import '../../domain/entities/topic_entity.dart';

sealed class TopicSelectionState extends Equatable {
  const TopicSelectionState();

  @override
  List<Object?> get props => [];
}

class TopicSelectionInitial extends TopicSelectionState {
  const TopicSelectionInitial();
}

class TopicSelectionLoading extends TopicSelectionState {
  const TopicSelectionLoading();
}

class TopicSelectionLoaded extends TopicSelectionState {
  final List<TopicEntity> topics;
  final String categoryId;

  const TopicSelectionLoaded({required this.topics, required this.categoryId});

  @override
  List<Object?> get props => [topics, categoryId];
}

class TopicSelectionError extends TopicSelectionState {
  final String message;
  const TopicSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}
