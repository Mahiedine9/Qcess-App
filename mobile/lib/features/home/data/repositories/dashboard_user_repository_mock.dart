import 'package:mobile/features/home/data/models/user_dashboard.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';

class DashboardUserRepositoryMock implements IDashboardUserRepository {

  @override
  Future<UserDashboard> getUserDashboard() async {
    await Future.delayed(Duration(milliseconds: 500));
    return UserDashboard(
      username: "John Doe",
      totalAccess: 106,
      lastAccess: DateTime.now(),
      profilePictureUrl: "https://i.pravatar.cc/150?img=12",
      totalZones: 5,
    );
  }
}