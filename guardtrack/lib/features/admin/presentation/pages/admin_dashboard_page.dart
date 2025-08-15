import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/admin_quick_actions.dart';
import '../widgets/admin_recent_activity.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: AppConstants.largePadding),
              _buildStatsGrid(),
              const SizedBox(height: AppConstants.largePadding),
              _buildQuickActions(),
              const SizedBox(height: AppConstants.largePadding),
              _buildRecentActivity(),
              const SizedBox(height: AppConstants.largePadding),
              _buildAnalyticsPreview(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: AppColors.white),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'Admin Portal',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.notifications_outlined, color: AppColors.white),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.white),
          onPressed: () {
            // Navigate to settings
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: AppColors.white),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                // Navigate to profile
                break;
              case 'logout':
                _handleLogout();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${state.user.user.firstName}!',
                  style:
                      AppTextStyles.heading2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Here\'s what\'s happening with your security operations today.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Text(
                      'Last login: ${_formatLastLogin()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.defaultPadding,
          mainAxisSpacing: AppConstants.defaultPadding,
          childAspectRatio: 1.5,
          children: const [
            AdminStatsCard(
              title: 'Total Employees',
              value: '156',
              icon: Icons.people_outline,
              color: AppColors.primaryBlue,
              trend: '+12 this month',
            ),
            AdminStatsCard(
              title: 'Active Sites',
              value: '24',
              icon: Icons.location_on_outlined,
              color: AppColors.accentGreen,
              trend: '+2 this week',
            ),
            AdminStatsCard(
              title: 'Attendance Rate',
              value: '94.2%',
              icon: Icons.check_circle_outline,
              color: AppColors.successGreen,
              trend: '+2.1% vs last month',
            ),
            AdminStatsCard(
              title: 'Active Alerts',
              value: '7',
              icon: Icons.warning_amber_outlined,
              color: AppColors.warningAmber,
              trend: '-3 from yesterday',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        const AdminQuickActions(),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3,
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity log
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        const AdminRecentActivity(),
      ],
    );
  }

  Widget _buildAnalyticsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analytics Preview',
              style: AppTextStyles.heading3,
            ),
            TextButton(
              onPressed: () {
                // Navigate to full analytics
              },
              child: const Text('View Details'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Container(
          height: 200,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Attendance Trends Chart\n(Chart implementation pending)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray500),
            ),
          ),
        ),
      ],
    );
  }

  String _formatLastLogin() {
    // Mock last login time
    final now = DateTime.now();
    final lastLogin = now.subtract(const Duration(hours: 2, minutes: 30));
    return '${lastLogin.hour.toString().padLeft(2, '0')}:${lastLogin.minute.toString().padLeft(2, '0')} today';
  }

  Future<void> _refreshDashboard() async {
    // TODO: Implement dashboard refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }

  void _handleLogout() {
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
          CustomButton(
            text: 'Logout',
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            type: ButtonType.text,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
