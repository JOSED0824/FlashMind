import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  final bool isLoginForm;
  const AuthInitial({this.isLoginForm = true});

  @override
  List<Object?> get props => [isLoginForm];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final bool isNewUser;

  const AuthSuccess(this.user, {this.isNewUser = false});

  @override
  List<Object?> get props => [user, isNewUser];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
