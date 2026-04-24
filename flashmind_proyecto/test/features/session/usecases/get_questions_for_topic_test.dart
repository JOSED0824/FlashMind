import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/session/domain/usecases/get_questions_for_topic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSessionRepository mockRepository;
  late GetQuestionsForTopic useCase;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = GetQuestionsForTopic(mockRepository);
  });

  test('devuelve Right con lista de preguntas cuando tiene éxito', () async {
    when(() => mockRepository.getQuestionsForTopic(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );

    final result = await useCase('topic1');

    expect(result.isRight, true);
    expect(result.right, [tQuestion, tQuestion2]);
    expect(result.right.length, 2);
  });

  test('devuelve Left(Failure) cuando falla', () async {
    when(() => mockRepository.getQuestionsForTopic(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Preguntas no encontradas')),
    );

    final result = await useCase('topic_x');

    expect(result.isLeft, true);
    expect(result.left.message, 'Preguntas no encontradas');
  });

  test('llama repository.getQuestionsForTopic con el topicId correcto',
      () async {
    when(() => mockRepository.getQuestionsForTopic(any())).thenAnswer(
      (_) async => Right([tQuestion]),
    );

    await useCase('topic1');

    verify(() => mockRepository.getQuestionsForTopic('topic1')).called(1);
  });
}
