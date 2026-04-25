import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/no_params.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;
  final AuthRepository _authRepository;

  AuthCubit({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LogoutUser logoutUser,
    required AuthRepository authRepository,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _logoutUser = logoutUser,
        _authRepository = authRepository,
        super(const AuthInitial());

  void toggleForm() {
    final current = state;
    final isLogin = current is AuthInitial ? current.isLoginForm : true;
    emit(AuthInitial(isLoginForm: !isLogin));
  }

  bool get isLoginForm {
    final current = state;
    return current is AuthInitial ? current.isLoginForm : true;
  }

  Future<void> checkCurrentUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (_) => null,
      (user) {
        if (user != null) {
          setCurrentUser(user.id, user.username);
          emit(AuthSuccess(user));
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await _loginUser(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        setCurrentUser(user.id, user.username);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> register(String username, String email, String password) async {
    emit(const AuthLoading());
    final result = await _registerUser(
      RegisterParams(username: username, email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        setCurrentUser(user.id, user.username);
        emit(AuthSuccess(user, isNewUser: true));
      },
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        setCurrentUser(user.id, user.username);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> logout() async {
    await _logoutUser(const NoParams());
    emit(const AuthInitial());
  }

  void updateUser(UserEntity updatedUser) {
    if (state is AuthSuccess) {
      setCurrentUser(updatedUser.id, updatedUser.username);
      emit(AuthSuccess(updatedUser));
    }
  }
}
