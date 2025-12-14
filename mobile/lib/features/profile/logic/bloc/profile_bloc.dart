import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';
import 'package:mobile/features/profile/data/repositories/i_profile_repository.dart';
import 'package:mobile/features/profile/logic/bloc/profile_event.dart';
import 'package:mobile/features/profile/logic/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfilePictureUpdateRequested>(_onProfilePictureUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await profileRepository.getMyProfile();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: 'Impossible de charger le profil'));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    try {
      final profile = await profileRepository.getMyProfile();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(
        message: 'Impossible de rafraîchir le profil',
        previousProfile: currentProfile,
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(ProfileUpdating(profile: currentProfile));
    try {
      final updatedProfile = await profileRepository.updateProfile(event.request);
      emit(ProfileUpdateSuccess(
        profile: updatedProfile,
        message: 'Profil mis à jour avec succès',
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Erreur lors de la mise à jour du profil',
        previousProfile: currentProfile,
      ));
    }
  }

  Future<void> _onProfilePictureUpdateRequested(
    ProfilePictureUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(ProfileUpdating(profile: currentProfile));
    try {
      final updatedProfile = await profileRepository.updateProfilePicture(event.imagePath);
      emit(ProfileUpdateSuccess(
        profile: updatedProfile,
        message: 'Photo de profil mise à jour',
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Erreur lors de la mise à jour de la photo',
        previousProfile: currentProfile,
      ));
    }
  }

  UserInfo? _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.profile;
    if (currentState is ProfileUpdating) return currentState.profile;
    if (currentState is ProfileUpdateSuccess) return currentState.profile;
    if (currentState is ProfileError) return currentState.previousProfile;
    return null;
  }
}