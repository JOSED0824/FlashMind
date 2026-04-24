import 'package:flashmind_proyecto/core/errors/failures.dart';
import 'package:flashmind_proyecto/core/utils/either.dart';
import 'package:flashmind_proyecto/core/utils/no_params.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/login_user.dart';
import 'package:flashmind_proyecto/features/auth/domain/usecases/register_user.dart';
import 'package:flashmind_proyecto/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flashmind_proyecto/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogoutUser mockLogoutUser;
  late MockAuthRepository mockAuthRepository;
  late AuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterParams(username: '', email: '', password: ''),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockLogoutUser = MockLogoutUser();
    mockAuthRepository = MockAuthRepository();
    cubit = AuthCubit(
      loginUser: mockLoginUser,
      registerUser: mockRegisterUser,
      logoutUser: mockLogoutUser,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() => cubit.close());

  // ── Estado inicial ──────────────────────────────────────────────────────────

  test('estado inicial es AuthInitial con isLoginForm = true', () {
    expect(cubit.state, const AuthInitial(isLoginForm: true));
  });

  // ── toggleForm ──────────────────────────────────────────────────────────────

  test('toggleForm cambia isLoginForm de true a false', () async {
    final future = cubit.stream.take(1).toList();
    cubit.toggleForm();
    expect(await future, [const AuthInitial(isLoginForm: false)]);
  });

  test('toggleForm cambia isLoginForm de false a true', () async {
    cubit.emit(const AuthInitial(isLoginForm: false));
    final future = cubit.stream.take(1).toList();
    cubit.toggleForm();
    expect(await future, [const AuthInitial(isLoginForm: true)]);
  });

  test('isLoginForm getter devuelve true por defecto', () {
    expect(cubit.isLoginForm, true);
  });

  // ── login ───────────────────────────────────────────────────────────────────

  test('login exitoso emite [AuthLoading, AuthSuccess]', () async {
    when(() => mockLoginUser(any())).thenAnswer((_) async => Right(tUser));
    final future = cubit.stream.take(2).toList();

    await cubit.login('test@test.com', 'password123');

    expect(await future, [const AuthLoading(), AuthSuccess(tUser)]);
  });

  test('login fallido emite [AuthLoading, AuthFailure]', () async {
    when(() => mockLoginUser(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Credenciales incorrectas')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.login('bad@email.com', 'wrong');

    expect(await future, [
      const AuthLoading(),
      const AuthFailure('Credenciales incorrectas'),
    ]);
  });

  test('login llama LoginUser con los params correctos', () async {
    when(() => mockLoginUser(any())).thenAnswer((_) async => Right(tUser));

    await cubit.login('user@app.com', 'pass123');

    final captured = verify(() => mockLoginUser(captureAny())).captured;
    final params = captured.single as LoginParams;
    expect(params.email, 'user@app.com');
    expect(params.password, 'pass123');
  });

  // ── register ────────────────────────────────────────────────────────────────

  test('register exitoso emite [AuthLoading, AuthSuccess]', () async {
    when(() => mockRegisterUser(any())).thenAnswer((_) async => Right(tUser));
    final future = cubit.stream.take(2).toList();

    await cubit.register('TestUser', 'test@test.com', 'pass123');

    expect(await future, [const AuthLoading(), AuthSuccess(tUser)]);
  });

  test('register fallido emite [AuthLoading, AuthFailure]', () async {
    when(() => mockRegisterUser(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Email ya registrado')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.register('User', 'existing@email.com', 'pass');

    expect(await future, [
      const AuthLoading(),
      const AuthFailure('Email ya registrado'),
    ]);
  });

  test('register llama RegisterUser con los params correctos', () async {
    when(() => mockRegisterUser(any())).thenAnswer((_) async => Right(tUser));

    await cubit.register('TestUser', 'test@test.com', 'pass123');

    final captured = verify(() => mockRegisterUser(captureAny())).captured;
    final params = captured.single as RegisterParams;
    expect(params.username, 'TestUser');
    expect(params.email, 'test@test.com');
    expect(params.password, 'pass123');
  });

  // ── signInWithGoogle ────────────────────────────────────────────────────────

  test('signInWithGoogle exitoso emite [AuthLoading, AuthSuccess]', () async {
    when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
      (_) async => Right(tUser),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.signInWithGoogle();

    expect(await future, [const AuthLoading(), AuthSuccess(tUser)]);
  });

  test('signInWithGoogle fallido emite [AuthLoading, AuthFailure]', () async {
    when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
      (_) async => const Left(CacheFailure('Inicio de sesión cancelado')),
    );
    final future = cubit.stream.take(2).toList();

    await cubit.signInWithGoogle();

    expect(await future, [
      const AuthLoading(),
      const AuthFailure('Inicio de sesión cancelado'),
    ]);
  });

  // ── logout ──────────────────────────────────────────────────────────────────

  test('logout emite AuthInitial', () async {
    when(() => mockLogoutUser(any())).thenAnswer(
      (_) async => Right<Failure, void>(null),
    );
    cubit.emit(AuthSuccess(tUser));
    final future = cubit.stream.take(1).toList();

    await cubit.logout();

    expect(await future, [const AuthInitial()]);
  });

  // ── checkCurrentUser ────────────────────────────────────────────────────────

  test('checkCurrentUser con usuario logueado emite AuthSuccess', () async {
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
      (_) async => Right(tUser),
    );
    final future = cubit.stream.take(1).toList();

    await cubit.checkCurrentUser();

    expect(await future, [AuthSuccess(tUser)]);
  });

  test('checkCurrentUser sin usuario no cambia estado', () async {
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
      (_) async => const Right(null),
    );

    await cubit.checkCurrentUser();

    expect(cubit.state, const AuthInitial());
  });
}
