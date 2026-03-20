import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract interface class FirebaseAuthDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSourceImpl(this._auth);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<UserEntity> register(
      String username, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(username.trim());
      await credential.user!.reload();
      return _mapUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  UserEntity _mapUser(User user) => UserEntity(
        id: user.uid,
        username: user.displayName ?? user.email!.split('@').first,
        email: user.email ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'Error de autenticación. Intenta de nuevo';
    }
  }
}
