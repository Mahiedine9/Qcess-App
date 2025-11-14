import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_event.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {

  final IDashboardUserRepository dashboardUserRepository;

  DashboardBloc({required this.dashboardUserRepository}) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final userDashboard = await dashboardUserRepository.getUserDashboard();
      emit(DashboardLoaded(userDashboard));
    } catch (e) {
      emit(DashboardError("Failed to load dashboard"));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final userDashboard = await dashboardUserRepository.getUserDashboard();
      emit(DashboardLoaded(userDashboard));
    } catch (e) {
      emit(DashboardError("Failed to refresh dashboard"));
    }
  }
}