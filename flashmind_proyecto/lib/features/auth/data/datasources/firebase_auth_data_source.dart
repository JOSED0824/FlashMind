import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract interface class FirebaseAuthDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updatePhotoUrl(String photoUrl);
  Future<UserEntity> updateUsername(String username);
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl(this._auth, this._googleSignIn);

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
  Future<UserEntity> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, signInWithPopup provides the idToken correctly
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        final userCredential = await _auth.signInWithPopup(provider);
        return _mapUser(userCredential.user!);
      } else {
        // On mobile, use google_sign_in package
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const ValidationException('Inicio de sesión con Google cancelado');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        return _mapUser(userCredential.user!);
      }
    } on ValidationException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapFirebaseError(e.code));
    } catch (_) {
      throw const ValidationException('Error al iniciar sesión con Google');
    }
  }

  @override
  Future<void> logout() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Future<UserEntity> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const ValidationException('No hay sesión activa');
      await user.updatePhotoURL(photoUrl);
      await user.reload();
      return _mapUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapFirebaseError(e.code));
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw const ValidationException('Error al actualizar la foto de perfil');
    }
  }

  @override
  Future<UserEntity> updateUsername(String username) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const ValidationException('No hay sesión activa');
      await user.updateDisplayName(username.trim());
      await user.reload();
      return _mapUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapFirebaseError(e.code));
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw const ValidationException('Error al actualizar el nombre');
    }
  }

  UserEntity _mapUser(User user) => UserEntity(
        id: user.uid,
        username: user.displayName ?? user.email!.split('@').first,
        email: user.email ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        photoUrl: user.photoURL,
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
      case 'popup-closed-by-user':
        return 'Inicio de sesión con Google cancelado';
      case 'popup-blocked':
        return 'Popup bloqueado. Permite popups en este sitio';
      default:
        return 'Error de autenticación. Intenta de nuevo';
    }
  }
}
