import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  LoadDashboard();

  @override
  List<Object?> get props => [];
}

class RefreshDashboard extends DashboardEvent {
  RefreshDashboard();

  @override
  List<Object?> get props => [];
}