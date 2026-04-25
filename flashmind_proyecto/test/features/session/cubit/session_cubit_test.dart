import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/features/session/presentation/cubit/session_cubit.dart';
import 'package:flashmind_proyecto/features/session/presentation/cubit/session_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockGetQuestionsForTopic mockGetQuestions;
  late MockSaveSessionResult mockSaveResult;
  late MockHomeLocalDataSource mockHomeDataSource;
  late MockSupabaseService mockSupabaseService;
  late SessionCubit cubit;

  setUpAll(() {
    registerFallbackValue(tResult);
  });

  setUp(() {
    mockGetQuestions = MockGetQuestionsForTopic();
    mockSaveResult = MockSaveSessionResult();
    mockHomeDataSource = MockHomeLocalDataSource();
    mockSupabaseService = MockSupabaseService();
    cubit = SessionCubit(
      getQuestionsForTopic: mockGetQuestions,
      saveSessionResult: mockSaveResult,
      homeDataSource: mockHomeDataSource,
      supabaseService: mockSupabaseService,
    );
  });

  tearDown(() => cubit.close());

  test('estado inicial es SessionInitial', () {
    expect(cubit.state, const SessionInitial());
  });

  // â”€â”€ startSession exitoso â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  test('startSession exitoso emite [SessionLoading, SessionInProgress]',
      () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.startSession('topic1', 'cat1', 'user1');

    final states = await future;
    expect(states[0], isA<SessionLoading>());
    expect(states[1], isA<SessionInProgress>());
  });

  test('startSession establece correctamente las preguntas y el Ã­ndice inicial',
      () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );

    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);

    final state = cubit.state as SessionInProgress;
    expect(state.questions, [tQuestion, tQuestion2]);
    expect(state.currentIndex, 0);
    expect(state.isAnswerRevealed, false);
    expect(state.currentPoints, 0);
  });

  test('startSession llama GetQuestionsForTopic con el topicId correcto',
      () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion]),
    );

    await cubit.startSession('topic1', 'cat1', 'user1');

    verify(() => mockGetQuestions('topic1')).called(1);
  });

  test('startSession fallido emite [SessionLoading, SessionError]', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Preguntas no encontradas')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.startSession('topic1', 'cat1', 'user1');

    expect(await future, [
      const SessionLoading(),
      const SessionError('Preguntas no encontradas'),
    ]);
  });

  // â”€â”€ selectOption â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  test('selectOption con respuesta correcta revela y suma puntos', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);

    final future = cubit.stream.take(1).toList();
    cubit.selectOption(0); // Ã­ndice 0 = correcto en tQuestion
    await future;

    final state = cubit.state as SessionInProgress;
    expect(state.isAnswerRevealed, true);
    expect(state.selectedOptionIndex, 0);
    expect(state.currentPoints, tQuestion.pointValue);
  });

  test('selectOption con respuesta incorrecta revela pero no suma puntos',
      () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);

    final future = cubit.stream.take(1).toList();
    cubit.selectOption(1); // Ã­ndice 1 = incorrecto en tQuestion
    await future;

    final state = cubit.state as SessionInProgress;
    expect(state.isAnswerRevealed, true);
    expect(state.selectedOptionIndex, 1);
    expect(state.currentPoints, 0);
  });

  test('selectOption cuando ya estÃ¡ revelada no cambia estado', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final firstFuture = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await firstFuture;

    // Intentar responder de nuevo
    final pointsAntes = (cubit.state as SessionInProgress).currentPoints;
    final secondFuture = cubit.stream.take(1).toList().timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => [],
        );
    cubit.selectOption(1);
    final extraStates = await secondFuture;

    expect(extraStates, isEmpty);
    expect((cubit.state as SessionInProgress).currentPoints, pointsAntes);
  });

  // â”€â”€ nextQuestion â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  test('nextQuestion avanza al siguiente Ã­ndice y limpia respuesta', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final f1 = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await f1;

    final f2 = cubit.stream.take(1).toList();
    cubit.nextQuestion();
    await f2;

    final state = cubit.state as SessionInProgress;
    expect(state.currentIndex, 1);
    expect(state.isAnswerRevealed, false);
    expect(state.selectedOptionIndex, isNull);
  });

  test('nextQuestion guarda la respuesta en la lista de answers', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion, tQuestion2]),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final f1 = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await f1;

    final f2 = cubit.stream.take(1).toList();
    cubit.nextQuestion();
    await f2;

    final state = cubit.state as SessionInProgress;
    expect(state.answers.length, 1);
    expect(state.answers.first.questionId, tQuestion.id);
    expect(state.answers.first.isCorrect, true);
  });

  test('nextQuestion en Ãºltima pregunta emite SessionComplete', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion]),
    );
    when(() => mockSaveResult(any())).thenAnswer(
      (_) async => const Right(null),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final f1 = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await f1;

    final f2 = cubit.stream.take(1).toList();
    cubit.nextQuestion();
    final states = await f2;

    expect(states[0], isA<SessionComplete>());
  });

  test('SessionComplete contiene topicId, respuestas correctas y puntos',
      () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion]),
    );
    when(() => mockSaveResult(any())).thenAnswer(
      (_) async => const Right(null),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final f1 = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await f1;

    final f2 = cubit.stream.take(1).toList();
    cubit.nextQuestion();
    await f2;

    final complete = cubit.state as SessionComplete;
    expect(complete.result.topicId, 'topic1');
    expect(complete.result.correctAnswers, 1);
    expect(complete.result.totalQuestions, 1);
    expect(complete.result.pointsEarned, tQuestion.pointValue);
  });

  test('nextQuestion en Ãºltima pregunta llama SaveSessionResult', () async {
    when(() => mockGetQuestions(any())).thenAnswer(
      (_) async => Right([tQuestion]),
    );
    when(() => mockSaveResult(any())).thenAnswer(
      (_) async => const Right(null),
    );
    await cubit.startSession('topic1', 'cat1', 'user1');
    await Future.delayed(Duration.zero);
    final f1 = cubit.stream.take(1).toList();
    cubit.selectOption(0);
    await f1;

    final f2 = cubit.stream.take(1).toList();
    cubit.nextQuestion();
    await f2;

    verify(() => mockSaveResult(any())).called(1);
  });

  // â”€â”€ nextQuestion sin sesiÃ³n activa â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  test('nextQuestion sin sesiÃ³n activa no cambia estado', () async {
    final future = cubit.stream.take(1).toList().timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => [],
        );
    cubit.nextQuestion();
    expect(await future, isEmpty);
    expect(cubit.state, const SessionInitial());
  });
}


