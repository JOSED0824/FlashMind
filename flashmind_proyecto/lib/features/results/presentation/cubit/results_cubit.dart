import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../results/data/datasources/results_local_data_source.dart';
import '../../../session/domain/entities/session_result_entity.dart';
import 'results_state.dart';

class ResultsCubit extends Cubit<ResultsState> {
  final ResultsLocalDataSource _dataSource;

  ResultsCubit({required ResultsLocalDataSource dataSource})
      : _dataSource = dataSource,
        super(const ResultsInitial());

  Future<void> loadResults(SessionResultEntity result) async {
    emit(const ResultsLoading());
    try {
      final achievements = await _dataSource.getAchievementsForResult(result);
      emit(ResultsLoaded(result: result, achievements: achievements));
    } catch (_) {
      emit(ResultsLoaded(result: result, achievements: const []));
    }
  }
}
