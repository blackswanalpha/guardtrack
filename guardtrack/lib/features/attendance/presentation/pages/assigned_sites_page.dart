import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../bloc/assigned_sites_bloc.dart';
import '../widgets/assigned_site_card.dart';

class AssignedSitesPage extends StatefulWidget {
  final UserModel user;

  const AssignedSitesPage({
    super.key,
    required this.user,
  });

  @override
  State<AssignedSitesPage> createState() => _AssignedSitesPageState();
}

class _AssignedSitesPageState extends State<AssignedSitesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AssignedSitesBloc>().add(
          AssignedSitesLoadRequested(widget.user.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: BlocConsumer<AssignedSitesBloc, AssignedSitesState>(
        listener: (context, state) {
          if (state is AssignedSitesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  context.read<AssignedSitesBloc>().add(
                        AssignedSitesRefreshed(widget.user.id),
                      );
                },
                child: _buildBody(state),
              ),
              if (state is AssignedSitesLoading)
                const LoadingOverlay(message: 'Loading sites...'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(AssignedSitesState state) {
    if (state is AssignedSitesLoaded && state.sites.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          _buildHeader(state),

          const SizedBox(height: 16),

          // Sites list
          if (state is AssignedSitesLoaded) ...[
            Text(
              'Your Assigned Sites',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...state.sites.map((site) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AssignedSiteCard(
                    site: site,
                    onTap: () => _showSiteDetails(site),
                  ),
                )),
          ],

          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildHeader(AssignedSitesState state) {
    final sitesCount = state is AssignedSitesLoaded ? state.sites.length : 0;
    final activeSites = state is AssignedSitesLoaded
        ? state.sites.where((site) => site.isActive).length
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sites Overview',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Sites',
                  sitesCount.toString(),
                  Icons.location_city,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Active Sites',
                  activeSites.toString(),
                  Icons.check_circle,
                  AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Sites Assigned',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t been assigned to any security sites yet. Contact your supervisor for site assignments.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AssignedSitesBloc>().add(
                      AssignedSitesRefreshed(widget.user.id),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSiteDetails(site) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        site.address,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add more site details here
                      Text(
                        'Site Details',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        site.description ?? 'No description available',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
