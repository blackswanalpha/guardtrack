import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class AdminRecentActivity extends StatelessWidget {
  const AdminRecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildActivityItem(
            icon: Icons.person_add,
            iconColor: AppColors.accentGreen,
            title: 'New Employee Added',
            subtitle: 'John Smith joined Site Alpha',
            time: '2 hours ago',
          ),
          const Divider(height: AppConstants.largePadding),
          _buildActivityItem(
            icon: Icons.warning,
            iconColor: AppColors.warningAmber,
            title: 'Late Arrival Alert',
            subtitle: 'Sarah Johnson - Site Beta (15 min late)',
            time: '3 hours ago',
          ),
          const Divider(height: AppConstants.largePadding),
          _buildActivityItem(
            icon: Icons.check_circle,
            iconColor: AppColors.successGreen,
            title: 'Assignment Completed',
            subtitle: 'Security patrol completed at Site Gamma',
            time: '4 hours ago',
          ),
          const Divider(height: AppConstants.largePadding),
          _buildActivityItem(
            icon: Icons.location_on,
            iconColor: AppColors.primaryBlue,
            title: 'New Site Added',
            subtitle: 'Downtown Office Complex configured',
            time: '6 hours ago',
          ),
          const Divider(height: AppConstants.largePadding),
          _buildActivityItem(
            icon: Icons.notifications,
            iconColor: Color(0xFF9C27B0),
            title: 'Notification Sent',
            subtitle: 'Monthly safety reminder to all guards',
            time: '8 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
