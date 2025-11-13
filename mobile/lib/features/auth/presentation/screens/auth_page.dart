import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        final horizontalPadding = context.horizontalPadding;
        final spacing = context.spacing;
        final maxContentWidth = ResponsiveUtils.getMaxContentWidth(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: spacing * 3.75),
                      Text(
                        'Connectez-Vous',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getScaledFontSize(context, 28),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: spacing * 0.75),
                      Text(
                        'Votre accès quotidien simplifié',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: spacing * 3),
                      const AuthForm(),
                      SizedBox(height: spacing * 3.75),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}