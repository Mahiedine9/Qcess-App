import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_event.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:mobile/features/profile/data/dto/update_profile_request.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';
import 'package:mobile/features/profile/logic/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/logic/bloc/profile_event.dart';
import 'package:mobile/features/profile/logic/bloc/profile_state.dart';
import 'package:mobile/features/profile/presentation/widgets/organization_card.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_app_bar.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_info_field.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_info_row.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserInfo profile) {
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _emailController.text = profile.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProfileError && state.previousProfile == null) {
            return _buildErrorState(state.message);
          }

          final profile = _extractProfile(state);
          if (profile == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return _buildProfileContent(profile, state is ProfileUpdating);
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      setState(() => _isEditing = false);
      _initializeControllers(state.profile);
      context.read<AuthBloc>().add(UpdateUserInfoEvent(userInfo :state.profile));
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    } else if (state is ProfileLoaded && !_isEditing) {
      _initializeControllers(state.profile);
    }
  }

  UserInfo? _extractProfile(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    if (state is ProfileError) return state.previousProfile;
    return null;
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<ProfileBloc>().add(ProfileLoadRequested()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  'Réessayer',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserInfo profile, bool isUpdating) {
    return CustomScrollView(
      controller: ScaffoldWithNavBar.getScrollController(
        1,
      ),
      slivers: [
        ProfileAppBar(
          imageUrl: profile.profilePictureUrl,
          initials: profile.initials,
          isEditing: _isEditing,
          onBackPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          onEditToggle: () => setState(() {
            _isEditing = !_isEditing;
            if (!_isEditing) _initializeControllers(profile);
          }),
          onChangePhoto: _onChangePhoto,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ProfileHeader(
                    displayName: profile.displayName,
                    email: profile.email,
                  ),

                  const SizedBox(height: 32),

                  _buildInfoSection(isUpdating),

                  const SizedBox(height: 16),

                  if (profile.organizationName != null)
                    OrganizationCard(
                      organizationName: profile.organizationName!,
                    ),

                  const SizedBox(height: 16),

                  _buildAccountInfoCard(profile),

                  const SizedBox(height: 16),

                  _buildDangerZone(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isUpdating) {
    return ProfileInfoCard(
      title: 'Informations personnelles',
      icon: Icons.person_outline,
      trailing: _buildSaveButton(isUpdating),
      children: [
        ProfileInfoField(
          icon: Icons.badge_outlined,
          label: 'Prénom',
          controller: _firstNameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        ProfileInfoField(
          icon: Icons.badge_outlined,
          label: 'Nom',
          controller: _lastNameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        ProfileInfoField(
          icon: Icons.email_outlined,
          label: 'Email',
          controller: _emailController,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget? _buildSaveButton(bool isUpdating) {
    if (isUpdating) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    if (_isEditing) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: ElevatedButton(
          onPressed: _onSaveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Enregistrer',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildAccountInfoCard(UserInfo profile) {
    return ProfileInfoCard(
      title: 'Informations du compte',
      icon: Icons.info_outline,
      children: [
        ProfileInfoRow(
          icon: Icons.fingerprint,
          label: 'Identifiant',
          value: '#${profile.id}',
        ),
        if (profile.createdAt != null) ...[
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Membre depuis',
            value: _formatDate(profile.createdAt!),
          ),
        ],
      ],
    );
  }

  Widget _buildDangerZone() {
    return ProfileInfoCard(
      title: 'Zone de danger',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<AuthBloc>().add(
                  LogoutRequested(token: authState.token),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _onChangePhoto() {
    _pickAndUploadProfilePhoto();
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (file == null) return;

      context.read<ProfileBloc>().add(
        ProfilePictureUpdateRequested(imagePath: file.path),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Téléchargement de la photo...'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la sélection: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onSaveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
        ProfileUpdateRequested(
          request: UpdateProfileRequest(
            firstName: _firstNameController.text.trim().isNotEmpty
                ? _firstNameController.text.trim()
                : null,
            lastName: _lastNameController.text.trim().isNotEmpty
                ? _lastNameController.text.trim()
                : null,
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
          ),
        ),
      );
    }
  }
}
