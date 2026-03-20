import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String username, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> _userBox;
  static const _currentUserKey = 'current_user_id';
  final Box _settingsBox;

  AuthLocalDataSourceImpl(this._userBox, this._settingsBox);

  @override
  Future<UserModel> login(String email, String password) async {
    final users = _userBox.values.where((u) => u.email == email.toLowerCase().trim());
    if (users.isEmpty) {
      throw const ValidationException('Correo o contraseña incorrectos');
    }
    final user = users.first;
    if (user.passwordHash != _hashPassword(password)) {
      throw const ValidationException('Correo o contraseña incorrectos');
    }
    await _settingsBox.put(_currentUserKey, user.id);
    return user;
  }

  @override
  Future<UserModel> register(String username, String email, String password) async {
    final exists = _userBox.values.any((u) => u.email == email.toLowerCase().trim());
    if (exists) {
      throw const ValidationException('Ya existe una cuenta con este correo');
    }
    final id = const Uuid().v4();
    final model = UserModel(
      id: id,
      username: username.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );
    await _userBox.put(id, model);
    await _settingsBox.put(_currentUserKey, id);
    return model;
  }

  @override
  Future<void> logout() async {
    await _settingsBox.delete(_currentUserKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = _settingsBox.get(_currentUserKey) as String?;
    if (userId == null) return null;
    return _userBox.get(userId);
  }

  String _hashPassword(String password) {
    // Simple hash for local-only auth — NOT for production use
    var hash = 0;
    for (var i = 0; i < password.length; i++) {
      hash = (hash * 31 + password.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
