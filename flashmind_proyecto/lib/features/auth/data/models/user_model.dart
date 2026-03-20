import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        createdAt: createdAt,
      );

  factory UserModel.fromEntity(UserEntity entity, String passwordHash) =>
      UserModel(
        id: entity.id,
        username: entity.username,
        email: entity.email,
        passwordHash: passwordHash,
        createdAt: entity.createdAt,
      );
}
