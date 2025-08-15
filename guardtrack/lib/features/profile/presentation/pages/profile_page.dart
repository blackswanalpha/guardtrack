import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/change_password_dialog.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildProfileInfo(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildMenuSection(context),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAccountSection(context),
              const SizedBox(height: AppConstants.largePadding),
              _buildLogoutButton(context),
              const SizedBox(height: AppConstants.largePadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  'Profile',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
            const SizedBox(height: AppConstants.largePadding),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.white.withOpacity(0.2),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              user.displayName,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: ProfileInfoCard(user: user),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Column(
          children: [
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Attendance History',
              subtitle: 'View your check-in records',
              onTap: () => _navigateToAttendanceHistory(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.location_on,
              title: 'My Sites',
              subtitle: 'View assigned locations',
              onTap: () => _navigateToMySites(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage notification settings',
              onTap: () => _navigateToNotifications(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () => _navigateToHelp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Column(
          children: [
            ProfileMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => _navigateToEditProfile(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showChangePasswordDialog(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _navigateToPrivacyPolicy(context),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigation will be handled by the app router
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return CustomButton(
            text: 'Logout',
            icon: Icons.logout,
            onPressed: isLoading ? null : () => _showLogoutDialog(context),
            type: ButtonType.outline,
            backgroundColor: AppColors.errorRed,
            textColor: AppColors.errorRed,
            isLoading: isLoading,
          );
        },
      ),
    );
  }

  void _navigateToAttendanceHistory(BuildContext context) {
    // TODO: Navigate to attendance history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance history coming soon')),
    );
  }

  void _navigateToMySites(BuildContext context) {
    // TODO: Navigate to my sites
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My sites coming soon')),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    // TODO: Navigate to notifications settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon')),
    );
  }

  void _navigateToHelp(BuildContext context) {
    // TODO: Navigate to help & support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon')),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // TODO: Navigate to edit profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon')),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    // TODO: Navigate to privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon')),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2024 GuardTrack. All rights reserved.',
      children: [
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
