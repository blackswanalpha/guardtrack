import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/models/user_model.dart';
import '../widgets/site_card.dart';
import '../widgets/location_status_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../sites/presentation/pages/assign_sites_page.dart';
import '../../../sites/presentation/pages/site_details_page.dart';
import '../../../attendance/presentation/pages/check_in_page.dart';

import '../../../../test_email_widget.dart';
import '../../../reports/presentation/pages/email_reports_page.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    backgroundImage: widget.user.profileImageUrl != null
                        ? NetworkImage(widget.user.profileImageUrl!)
                        : null,
                    child: widget.user.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: AppColors.white,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          widget.user.displayName,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleNotifications,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DashboardError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () =>
                        context.read<DashboardBloc>().add(LoadDashboardData()),
                    type: ButtonType.outline,
                    isFullWidth: false,
                    width: 120,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return SliverList(
            delegate: SliverChildListDelegate([
              _buildLocationStatus(state.currentPosition),
              _buildQuickActions(state),
              _buildAssignedSites(state.assignedSites, state.currentPosition),
              const SizedBox(height: AppConstants.largePadding),
            ]),
          );
        }

        return const SliverFillRemaining(
          child: Center(
            child: Text('No data available'),
          ),
        );
      },
    );
  }

  Widget _buildLocationStatus(Position? position) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: LocationStatusWidget(
        position: position,
        onLocationTap: _handleLocationTap,
      ),
    );
  }

  Widget _buildQuickActions(DashboardLoaded state) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Check In',
                  icon: Icons.location_on,
                  onPressed: state.canCheckIn ? _handleCheckIn : null,
                  type: ButtonType.primary,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Check Out',
                  icon: Icons.location_off,
                  onPressed: state.canCheckOut ? _handleCheckOut : null,
                  type: ButtonType.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomButton(
            text: '📧 Email Reports',
            icon: Icons.email,
            onPressed: _handleEmailReports,
            type: ButtonType.primary,
            backgroundColor: AppColors.accentGreen,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          CustomButton(
            text: '🧪 Test Email Service',
            icon: Icons.science,
            onPressed: _handleEmailTest,
            type: ButtonType.outline,
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedSites(List<SiteModel> sites, Position? currentPosition) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assigned Sites',
                style: AppTextStyles.heading4,
              ),
              TextButton(
                onPressed: _handleViewAllSites,
                child: Text(
                  'View All',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          if (sites.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sites.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppConstants.defaultPadding),
              itemBuilder: (context, index) {
                final site = sites[index];
                return SiteCard(
                  site: site,
                  currentPosition: currentPosition,
                  onTap: () => _handleSiteTap(site),
                  onCheckIn: () => _handleSiteCheckIn(site),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Sites Assigned',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Contact your administrator to get assigned to sites.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    context.read<DashboardBloc>().add(RefreshDashboardData());
  }

  void _handleNotifications() {
    // TODO: Navigate to notifications page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications coming soon')),
    );
  }

  void _handleLocationTap() {
    context.read<DashboardBloc>().add(RefreshLocation());
  }

  void _handleCheckIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckInPage(user: widget.user),
      ),
    );
  }

  void _handleCheckOut() {
    // TODO: Navigate to check-out flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out functionality coming soon')),
    );
  }

  void _handleEmailReports() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmailReportsPage(user: widget.user),
      ),
    );
  }

  void _handleViewAllSites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssignSitesPage(user: widget.user),
      ),
    );
  }

  void _handleSiteTap(SiteModel site) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SiteDetailsPage(site: site),
      ),
    );
  }

  void _handleEmailTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmailTestWidget(),
      ),
    );
  }

  void _handleSiteCheckIn(SiteModel site) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckInPage(user: widget.user),
      ),
    );
  }
}
