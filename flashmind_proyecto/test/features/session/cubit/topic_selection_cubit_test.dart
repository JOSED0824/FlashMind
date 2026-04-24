import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/session/presentation/cubit/topic_selection_cubit.dart';
import 'package:flashmind_proyecto/features/session/presentation/cubit/topic_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockGetTopicsByCategory mockGetTopics;
  late TopicSelectionCubit cubit;

  setUp(() {
    mockGetTopics = MockGetTopicsByCategory();
    cubit = TopicSelectionCubit(getTopicsByCategory: mockGetTopics);
  });

  tearDown(() => cubit.close());

  test('estado inicial es TopicSelectionInitial', () {
    expect(cubit.state, const TopicSelectionInitial());
  });

  test('loadTopics exitoso emite [TopicSelectionLoading, TopicSelectionLoaded]',
      () async {
    when(() => mockGetTopics(any())).thenAnswer(
      (_) async => Right([tTopic]),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadTopics('cat1');

    expect(await future, [
      const TopicSelectionLoading(),
      TopicSelectionLoaded(topics: [tTopic], categoryId: 'cat1'),
    ]);
  });

  test('loadTopics guarda el categoryId y los topics en el estado', () async {
    when(() => mockGetTopics(any())).thenAnswer(
      (_) async => Right([tTopic]),
    );

    await cubit.loadTopics('cat1');
    await Future.delayed(Duration.zero);

    final state = cubit.state as TopicSelectionLoaded;
    expect(state.categoryId, 'cat1');
    expect(state.topics, [tTopic]);
  });

  test('loadTopics llama GetTopicsByCategory con el categoryId correcto',
      () async {
    when(() => mockGetTopics(any())).thenAnswer(
      (_) async => Right([tTopic]),
    );

    await cubit.loadTopics('cat42');

    verify(() => mockGetTopics('cat42')).called(1);
  });

  test(
      'loadTopics fallido emite '
      '[TopicSelectionLoading, TopicSelectionError]', () async {
    when(() => mockGetTopics(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Categoría no encontrada')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.loadTopics('cat_x');

    expect(await future, [
      const TopicSelectionLoading(),
      const TopicSelectionError('Categoría no encontrada'),
    ]);
  });

  test('loadTopics con lista vacía emite TopicSelectionLoaded vacío', () async {
    when(() => mockGetTopics(any())).thenAnswer(
      (_) async => Right([]),
    );

    await cubit.loadTopics('cat1');
    await Future.delayed(Duration.zero);

    expect((cubit.state as TopicSelectionLoaded).topics, isEmpty);
  });
}
