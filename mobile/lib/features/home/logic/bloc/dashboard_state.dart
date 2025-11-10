import 'package:equatable/equatable.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

abstract class DashboardState extends Equatable{
  final int? userId;

  const DashboardState({this.userId});

  @override
  List<Object?> get props => [userId];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super(userId: null);
}

class DashboardLoading extends DashboardState {
  const DashboardLoading(int userId) : super(userId: userId);
}

class DashboardLoaded extends DashboardState {
  final UserDashboard userDashboard;

  const DashboardLoaded(this.userDashboard, int userId) : super(userId: userId);

  @override
  List<Object?> get props => [userDashboard, userId];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message, {int? userId}) : super(userId: userId);

  @override
  List<Object?> get props => [message, userId];
}