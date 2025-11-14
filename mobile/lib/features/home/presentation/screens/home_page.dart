import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/widgets/error_widget.dart';
import 'package:mobile/core/presentation/widgets/loading_widget.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_event.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_state.dart';
import 'package:mobile/features/home/presentation/widgets/access_status_card.dart';
import 'package:mobile/features/home/presentation/widgets/feature_grid.dart';
import 'package:mobile/features/home/presentation/widgets/stats_row.dart';
import 'package:mobile/features/home/presentation/widgets/user_profile_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const LoadingWidget();
            }
            if (state is DashboardError) {
              return _buildError(context, state.message);
            }
            if (state is DashboardLoaded) {
              return _buildContent(context, state.userDashboard);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final dashboardBloc = context.read<DashboardBloc>();
    final userId = dashboardBloc.state.userId;

    return ErrorDisplayWidget(
      message: message,
      onRetry: userId != null
          ? () => dashboardBloc.add(LoadDashboard())
          : null,
    );
  }

  Widget _buildContent(BuildContext context, UserDashboard dashboard) {
    final dashboardBloc = context.read<DashboardBloc>();

    final horizontalPadding = context.horizontalPadding;
    final verticalPadding = context.verticalPadding;
    final spacing = context.spacing;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        dashboardBloc.add(RefreshDashboard());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding * 2,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          // TODO: Notifications
                        },
                      ),
                    ],
                  ),
                  UserProfileHeader(dashboard: dashboard),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(spacing * 2),
                  topRight: Radius.circular(spacing * 2),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: spacing * 1.5),
                    AccessStatusCard(lastAccess: dashboard.lastAccess),
                    SizedBox(height: spacing),
                    StatsRow(dashboard: dashboard),
                    SizedBox(height: spacing * 1.5),
                    const FeatureGrid(),
                    SizedBox(height: spacing * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}