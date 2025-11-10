import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final int userId;

  LoadDashboard(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshDashboard extends DashboardEvent {
  final int userId;

  RefreshDashboard(this.userId);

  @override
  List<Object?> get props => [userId];
}