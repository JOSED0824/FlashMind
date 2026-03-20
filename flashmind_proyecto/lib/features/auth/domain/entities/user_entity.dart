import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, username, email, createdAt];
}
