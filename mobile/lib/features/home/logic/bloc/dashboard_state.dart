import 'package:equatable/equatable.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

abstract class DashboardState extends Equatable{
  final int? userId;

  const DashboardState({this.userId});

  @override
  List<Object?> get props => [userId];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading() : super();
}

class DashboardLoaded extends DashboardState {
  final UserDashboard userDashboard;

  const DashboardLoaded(this.userDashboard) : super();

  @override
  List<Object?> get props => [userDashboard];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message) : super();

  @override
  List<Object?> get props => [message];
}