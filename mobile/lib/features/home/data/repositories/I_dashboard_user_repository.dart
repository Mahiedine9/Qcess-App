import 'package:mobile/features/home/data/models/user_dashboard.dart';

abstract class IDashboardUserRepository {
  Future<UserDashboard> getUserDashboard();
}