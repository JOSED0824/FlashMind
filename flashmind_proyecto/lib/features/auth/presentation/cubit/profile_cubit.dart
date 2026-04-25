import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/either.dart';
import '../../../../services/cloudinary_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/update_user_photo.dart';
import '../../domain/usecases/update_username.dart';

// ── States ────────────────────────────────────────────────────────────────────

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

class ProfileUploading extends ProfileState {
  const ProfileUploading();
}

class ProfileUploadSuccess extends ProfileState {
  final UserEntity updatedUser;
  const ProfileUploadSuccess(this.updatedUser);
  @override
  List<Object?> get props => [updatedUser];
}

class ProfileUploadFailure extends ProfileState {
  final String message;
  const ProfileUploadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileUpdatingUsername extends ProfileState {
  const ProfileUpdatingUsername();
}

class ProfileUsernameUpdated extends ProfileState {
  final UserEntity updatedUser;
  const ProfileUsernameUpdated(this.updatedUser);
  @override
  List<Object?> get props => [updatedUser];
}

class ProfileUsernameFailure extends ProfileState {
  final String message;
  const ProfileUsernameFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  final CloudinaryService _cloudinaryService;
  final UpdateUserPhoto _updateUserPhoto;
  final UpdateUsername _updateUsername;

  ProfileCubit({
    required CloudinaryService cloudinaryService,
    required UpdateUserPhoto updateUserPhoto,
    required UpdateUsername updateUsername,
  })  : _cloudinaryService = cloudinaryService,
        _updateUserPhoto = updateUserPhoto,
        _updateUsername = updateUsername,
        super(const ProfileIdle());

  Future<void> uploadPhoto(XFile imageFile, UserEntity currentUser) async {
    emit(const ProfileUploading());
    try {
      final cloudinaryUrl =
          await _cloudinaryService.uploadProfilePhoto(imageFile);

      final result = await _updateUserPhoto(
        UpdateUserPhotoParams(photoUrl: cloudinaryUrl),
      );

      result.fold(
        (failure) => emit(ProfileUploadFailure(failure.message)),
        (updatedUser) => emit(ProfileUploadSuccess(updatedUser)),
      );
    } on CloudinaryException catch (e) {
      emit(ProfileUploadFailure(e.message));
    } catch (_) {
      emit(const ProfileUploadFailure(
          'Error al subir la foto. Intenta de nuevo.'));
    }
  }

  Future<void> changeUsername(String newUsername) async {
    final trimmed = newUsername.trim();
    if (trimmed.isEmpty) {
      emit(const ProfileUsernameFailure('El nombre no puede estar vacío'));
      return;
    }
    if (trimmed.length < 3) {
      emit(const ProfileUsernameFailure('Mínimo 3 caracteres'));
      return;
    }
    emit(const ProfileUpdatingUsername());
    final result = await _updateUsername(UpdateUsernameParams(username: trimmed));
    result.fold(
      (failure) => emit(ProfileUsernameFailure(failure.message)),
      (updatedUser) => emit(ProfileUsernameUpdated(updatedUser)),
    );
  }

  void resetToIdle() => emit(const ProfileIdle());
}
