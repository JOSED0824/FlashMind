import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/either.dart';
import '../../domain/usecases/get_topics_by_category.dart';
import 'topic_selection_state.dart';

class TopicSelectionCubit extends Cubit<TopicSelectionState> {
  final GetTopicsByCategory _getTopicsByCategory;

  TopicSelectionCubit({required GetTopicsByCategory getTopicsByCategory})
      : _getTopicsByCategory = getTopicsByCategory,
        super(const TopicSelectionInitial());

  Future<void> loadTopics(String categoryId) async {
    emit(const TopicSelectionLoading());
    final result = await _getTopicsByCategory(categoryId);
    result.fold(
      (failure) => emit(TopicSelectionError(failure.message)),
      (topics) => emit(TopicSelectionLoaded(topics: topics, categoryId: categoryId)),
    );
  }
}
