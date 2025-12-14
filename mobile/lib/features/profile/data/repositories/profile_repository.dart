import 'package:dio/dio.dart';
import 'package:mobile/core/network/base_api_repository.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';
import 'package:mobile/features/profile/data/dto/update_profile_request.dart';
import 'package:mobile/features/profile/data/repositories/i_profile_repository.dart';

class ProfileRepository extends BaseApiRepository implements IProfileRepository {
  static const String _basePath = '/api/users';

  ProfileRepository(Dio dio) : super(dio);

  @override
  Future<UserInfo> getMyProfile() async {
    return get<UserInfo>(
      '$_basePath/me',
      fromJson: (data) => UserInfo.fromJson(data),
    );
  }

  @override
  Future<UserInfo> updateProfile(UpdateProfileRequest request) async {
    return put<UserInfo>(
      '$_basePath/me',
      data: request.toJson(),
      fromJson: (data) => UserInfo.fromJson(data),
    );
  }

  @override
  Future<UserInfo> updateProfilePicture(String imagePath) async {
    try {
      final fileName = imagePath.split('/')..removeWhere((e) => e.isEmpty);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName.isNotEmpty ? fileName.last : null,
        ),
      });

      final response = await dio.put(
        '$_basePath/me/profile-picture',
        data: formData,
      );

      return UserInfo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
