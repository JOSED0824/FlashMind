import 'package:flashmind_proyecto/features/results/presentation/cubit/results_cubit.dart';
import 'package:flashmind_proyecto/features/results/presentation/cubit/results_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockResultsLocalDataSource mockDataSource;
  late ResultsCubit cubit;

  setUpAll(() {
    registerFallbackValue(tResult);
  });

  setUp(() {
    mockDataSource = MockResultsLocalDataSource();
    cubit = ResultsCubit(dataSource: mockDataSource);
  });

  tearDown(() => cubit.close());

  test('estado inicial es ResultsInitial', () {
    expect(cubit.state, const ResultsInitial());
  });

  test('loadResults exitoso emite [ResultsLoading, ResultsLoaded]', () async {
    when(() => mockDataSource.getAchievementsForResult(any())).thenAnswer(
      (_) async => [tAchievement],
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadResults(tResult);

    expect(await future, [
      const ResultsLoading(),
      ResultsLoaded(result: tResult, achievements: [tAchievement]),
    ]);
  });

  test('loadResults con lista vacía emite ResultsLoaded con achievements vacío',
      () async {
    when(() => mockDataSource.getAchievementsForResult(any())).thenAnswer(
      (_) async => [],
    );

    await cubit.loadResults(tResult);
    await Future.delayed(Duration.zero);

    final state = cubit.state as ResultsLoaded;
    expect(state.achievements, isEmpty);
    expect(state.result, tResult);
  });

  test('loadResults con excepción emite ResultsLoaded con achievements vacío',
      () async {
    when(() => mockDataSource.getAchievementsForResult(any())).thenThrow(
      Exception('Error inesperado'),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadResults(tResult);

    expect(await future, [
      const ResultsLoading(),
      ResultsLoaded(result: tResult, achievements: const []),
    ]);
  });

  test('loadResults pasa el resultado correcto al datasource', () async {
    when(() => mockDataSource.getAchievementsForResult(any())).thenAnswer(
      (_) async => [],
    );

    await cubit.loadResults(tResult);

    verify(() => mockDataSource.getAchievementsForResult(tResult)).called(1);
  });
}
