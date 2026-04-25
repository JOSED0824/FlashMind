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

  @HiveField(5)
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.photoUrl,
  });

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        createdAt: createdAt,
        photoUrl: photoUrl,
      );

  factory UserModel.fromEntity(UserEntity entity, String passwordHash) =>
      UserModel(
        id: entity.id,
        username: entity.username,
        email: entity.email,
        passwordHash: passwordHash,
        createdAt: entity.createdAt,
        photoUrl: entity.photoUrl,
      );

  UserModel withPhotoUrl(String? url) => UserModel(
        id: id,
        username: username,
        email: email,
        passwordHash: passwordHash,
        createdAt: createdAt,
        photoUrl: url,
      );
}
