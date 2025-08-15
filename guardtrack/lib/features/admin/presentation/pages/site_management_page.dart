import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class SiteManagementPage extends StatefulWidget {
  const SiteManagementPage({super.key});

  @override
  State<SiteManagementPage> createState() => _SiteManagementPageState();
}

class _SiteManagementPageState extends State<SiteManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Site Management',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.white),
            onPressed: () {
              // Navigate to map view
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              'Active Sites',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildSitesList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "site_management_fab",
        onPressed: () {
          // Navigate to add site
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Sites',
            value: '24',
            color: AppColors.primaryBlue,
            icon: Icons.location_on,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildStatCard(
            title: 'Active Guards',
            value: '142',
            color: AppColors.accentGreen,
            icon: Icons.security,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildStatCard(
            title: 'Coverage',
            value: '96%',
            color: AppColors.successGreen,
            icon: Icons.shield,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSitesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) {
        final siteNames = [
          'Downtown Office Complex',
          'Industrial Park Alpha',
          'Shopping Mall Beta',
          'Residential Complex Gamma',
          'Corporate Headquarters',
          'Warehouse District',
          'Medical Center',
          'University Campus',
        ];

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siteNames[index],
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Site ID: SITE-${(index + 1).toString().padLeft(3, '0')}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 16, color: AppColors.gray600),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 2} Guards Assigned',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Icon(Icons.access_time, size: 16, color: AppColors.gray600),
                    const SizedBox(width: 4),
                    Text(
                      '24/7 Coverage',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Icon(Icons.location_searching,
                        size: 16, color: AppColors.gray600),
                    const SizedBox(width: 4),
                    Text(
                      'Geofence: ${50 + (index * 10)}m radius',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // View site details
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
