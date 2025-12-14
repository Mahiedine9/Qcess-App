import 'package:mobile/features/profile/data/dto/update_profile_request.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';

abstract class IProfileRepository {
  Future<UserInfo> getMyProfile();
  Future<UserInfo> updateProfile(UpdateProfileRequest request);
  Future<UserInfo> updateProfilePicture(String imagePath);
}
