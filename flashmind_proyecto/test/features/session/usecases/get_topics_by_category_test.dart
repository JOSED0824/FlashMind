import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/get_topics_by_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSessionRepository mockRepository;
  late GetTopicsByCategory useCase;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = GetTopicsByCategory(mockRepository);
  });

  test('devuelve Right con lista de topics cuando tiene éxito', () async {
    when(() => mockRepository.getTopicsByCategory(any())).thenAnswer(
      (_) async => Right([tTopic]),
    );

    final result = await useCase('cat1');

    expect(result.isRight, true);
    expect(result.right, [tTopic]);
  });

  test('devuelve Left(Failure) cuando falla', () async {
    when(() => mockRepository.getTopicsByCategory(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Categoría no encontrada')),
    );

    final result = await useCase('cat_x');

    expect(result.isLeft, true);
    expect(result.left.message, 'Categoría no encontrada');
  });

  test('llama repository.getTopicsByCategory con el categoryId correcto',
      () async {
    when(() => mockRepository.getTopicsByCategory(any())).thenAnswer(
      (_) async => Right([tTopic]),
    );

    await useCase('cat1');

    verify(() => mockRepository.getTopicsByCategory('cat1')).called(1);
  });

  test('devuelve lista vacía si la categoría no tiene topics', () async {
    when(() => mockRepository.getTopicsByCategory(any())).thenAnswer(
      (_) async => Right([]),
    );

    final result = await useCase('cat_empty');

    expect(result.right, isEmpty);
  });
}
