import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/features/profile/data/dto/update_profile_request.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';
import 'package:mobile/features/profile/data/repositories/i_profile_repository.dart';
import 'package:mobile/features/profile/logic/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/logic/bloc/profile_event.dart';
import 'package:mobile/features/profile/logic/bloc/profile_state.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([IProfileRepository])
void main() {
  late ProfileBloc profileBloc;
  late MockIProfileRepository mockProfileRepository;

  const testProfile = UserInfo(
    id: 1,
    email: 'test@example.com',
    firstName: 'John',
    lastName: 'Doe',
    fullName: 'John Doe',
    role: 'USER',
    userStatus: 'ACTIVE',
    organisationId: 1,
    organizationName: 'Test Org',
    profilePictureUrl: null,
  );

  const updatedProfile = UserInfo(
    id: 1,
    email: 'updated@example.com',
    firstName: 'Jane',
    lastName: 'Doe',
    fullName: 'Jane Doe',
    role: 'USER',
    userStatus: 'ACTIVE',
    organisationId: 1,
    organizationName: 'Test Org',
    profilePictureUrl: null,
  );

  const profileWithPicture = UserInfo(
    id: 1,
    email: 'test@example.com',
    firstName: 'John',
    lastName: 'Doe',
    fullName: 'John Doe',
    role: 'USER',
    userStatus: 'ACTIVE',
    organisationId: 1,
    organizationName: 'Test Org',
    profilePictureUrl: '/static/avatars/1/test.jpg',
  );

  setUp(() {
    mockProfileRepository = MockIProfileRepository();
    profileBloc = ProfileBloc(profileRepository: mockProfileRepository);
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      expect(profileBloc.state, isA<ProfileInitial>());
    });

    group('ProfileLoadRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when getMyProfile succeeds',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenAnswer((_) async => testProfile);
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileLoadRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', testProfile),
        ],
        verify: (_) {
          verify(mockProfileRepository.getMyProfile()).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when getMyProfile fails',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenThrow(Exception('Network error'));
          return profileBloc;
        },
        act: (bloc) => bloc.add(ProfileLoadRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>().having(
            (state) => state.message,
            'message',
            'Impossible de charger le profil',
          ),
        ],
      );
    });

    group('ProfileRefreshRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoaded] when refresh succeeds',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenAnswer((_) async => updatedProfile);
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) => bloc.add(ProfileRefreshRequested()),
        expect: () => [
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', updatedProfile),
        ],
        verify: (_) {
          verify(mockProfileRepository.getMyProfile()).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileError] with previousProfile when refresh fails',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenThrow(Exception('Network error'));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) => bloc.add(ProfileRefreshRequested()),
        expect: () => [
          isA<ProfileError>()
              .having((state) => state.message, 'message',
                  'Impossible de rafraîchir le profil')
              .having((state) => state.previousProfile, 'previousProfile',
                  testProfile),
        ],
      );
    });

    group('ProfileUpdateRequested', () {
      const updateRequest = UpdateProfileRequest(
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'updated@example.com',
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileUpdateSuccess] when updateProfile succeeds',
        build: () {
          when(mockProfileRepository.updateProfile(updateRequest))
              .thenAnswer((_) async => updatedProfile);
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) => bloc.add(ProfileUpdateRequested(request: updateRequest)),
        expect: () => [
          isA<ProfileUpdating>()
              .having((state) => state.profile, 'profile', testProfile),
          isA<ProfileUpdateSuccess>()
              .having((state) => state.profile, 'profile', updatedProfile)
              .having((state) => state.message, 'message',
                  'Profil mis à jour avec succès'),
        ],
        verify: (_) {
          verify(mockProfileRepository.updateProfile(updateRequest)).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when updateProfile fails',
        build: () {
          when(mockProfileRepository.updateProfile(updateRequest))
              .thenThrow(Exception('Update failed'));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) => bloc.add(ProfileUpdateRequested(request: updateRequest)),
        expect: () => [
          isA<ProfileUpdating>()
              .having((state) => state.profile, 'profile', testProfile),
          isA<ProfileError>()
              .having((state) => state.message, 'message',
                  'Erreur lors de la mise à jour du profil')
              .having((state) => state.previousProfile, 'previousProfile',
                  testProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(ProfileUpdateRequested(request: updateRequest)),
        expect: () => [],
        verify: (_) {
          verifyNever(mockProfileRepository.updateProfile(any));
        },
      );
    });

    group('ProfilePictureUpdateRequested', () {
      const testImagePath = '/path/to/image.jpg';

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileUpdateSuccess] when updateProfilePicture succeeds',
        build: () {
          when(mockProfileRepository.updateProfilePicture(testImagePath))
              .thenAnswer((_) async => profileWithPicture);
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) =>
            bloc.add(ProfilePictureUpdateRequested(imagePath: testImagePath)),
        expect: () => [
          isA<ProfileUpdating>()
              .having((state) => state.profile, 'profile', testProfile),
          isA<ProfileUpdateSuccess>()
              .having((state) => state.profile, 'profile', profileWithPicture)
              .having((state) => state.message, 'message',
                  'Photo de profil mise à jour'),
        ],
        verify: (_) {
          verify(mockProfileRepository.updateProfilePicture(testImagePath))
              .called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when updateProfilePicture fails',
        build: () {
          when(mockProfileRepository.updateProfilePicture(testImagePath))
              .thenThrow(Exception('Upload failed'));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: testProfile),
        act: (bloc) =>
            bloc.add(ProfilePictureUpdateRequested(imagePath: testImagePath)),
        expect: () => [
          isA<ProfileUpdating>()
              .having((state) => state.profile, 'profile', testProfile),
          isA<ProfileError>()
              .having((state) => state.message, 'message',
                  'Erreur lors de la mise à jour de la photo')
              .having((state) => state.previousProfile, 'previousProfile',
                  testProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) =>
            bloc.add(ProfilePictureUpdateRequested(imagePath: testImagePath)),
        expect: () => [],
        verify: (_) {
          verifyNever(mockProfileRepository.updateProfilePicture(any));
        },
      );
    });

    group('state preservation', () {
      blocTest<ProfileBloc, ProfileState>(
        'preserves profile from ProfileUpdating state',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenAnswer((_) async => updatedProfile);
          return profileBloc;
        },
        seed: () => ProfileUpdating(profile: testProfile),
        act: (bloc) => bloc.add(ProfileRefreshRequested()),
        expect: () => [
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', updatedProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'preserves profile from ProfileUpdateSuccess state',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenThrow(Exception('Error'));
          return profileBloc;
        },
        seed: () => ProfileUpdateSuccess(
          profile: testProfile,
          message: 'Previous success',
        ),
        act: (bloc) => bloc.add(ProfileRefreshRequested()),
        expect: () => [
          isA<ProfileError>()
              .having((state) => state.previousProfile, 'previousProfile',
                  testProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'preserves profile from ProfileError state',
        build: () {
          when(mockProfileRepository.getMyProfile())
              .thenThrow(Exception('Error again'));
          return profileBloc;
        },
        seed: () => ProfileError(
          message: 'Previous error',
          previousProfile: testProfile,
        ),
        act: (bloc) => bloc.add(ProfileRefreshRequested()),
        expect: () => [
          isA<ProfileError>()
              .having((state) => state.previousProfile, 'previousProfile',
                  testProfile),
        ],
      );
    });
  });
}
