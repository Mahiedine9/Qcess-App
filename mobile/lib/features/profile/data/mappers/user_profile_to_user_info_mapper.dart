import 'package:mobile/features/auth/data/models/user_info.dart';
import 'package:mobile/features/profile/data/models/user_profile.dart';


class UserProfileToUserInfoMapper {
  static UserInfo map(UserProfile profile) {
    return UserInfo(
      id: profile.id,
      email: profile.email,
      fullName: profile.fullName,
      firstName: profile.firstName,
      lastName: profile.lastName,
      role: profile.role ?? 'USER',
      customRoleName: null,
      organizationId: profile.organisationId,
      profilePictureUrl: profile.profilePictureUrl,
    );
  }
}
