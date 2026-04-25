import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    String? photoUrl,
    bool clearPhoto = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
    );
  }

  @override
  List<Object?> get props => [id, username, email, createdAt, photoUrl];
}
