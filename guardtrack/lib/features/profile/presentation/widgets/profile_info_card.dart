import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel user;

  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: user.fullName,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            if (user.phone != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone!,
              ),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: _formatRole(user.role),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: DateFormat('MMMM yyyy').format(user.createdAt),
            ),
            if (user.assignedSiteIds != null && user.assignedSiteIds!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Assigned Sites',
                value: '${user.assignedSiteIds!.length} site${user.assignedSiteIds!.length == 1 ? '' : 's'}',
              ),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            _buildStatusRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.gray500,
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 20,
          color: AppColors.gray500,
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Status',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: user.isActive ? AppColors.accentGreen : AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: user.isActive ? AppColors.accentGreen : AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRole(UserRole role) {
    switch (role) {
      case UserRole.guard:
        return 'Security Guard';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.superAdmin:
        return 'Super Administrator';
    }
  }
}
