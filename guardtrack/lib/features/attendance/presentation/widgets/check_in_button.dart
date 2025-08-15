import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/widgets/custom_button.dart';

class CheckInButton extends StatelessWidget {
  final SiteModel site;
  final Position? currentPosition;
  final bool isLoading;
  final bool? canCheckIn;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const CheckInButton({
    super.key,
    required this.site,
    this.currentPosition,
    required this.isLoading,
    this.canCheckIn,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final canPerformAction = canCheckIn ?? _canPerformAction();
    final distance = _calculateDistance();
    final isWithinRange = distance != null && distance <= site.geofenceRadius;

    return Container(
      width: double.infinity,
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
            'Check-in Actions',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 12),

          // Status indicators
          if (!canPerformAction) ...[
            _buildWarningMessage(),
            const SizedBox(height: 16),
          ],

          // Check-in/Check-out buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Check In',
                  onPressed: canPerformAction && !isLoading ? onCheckIn : null,
                  backgroundColor: AppColors.successGreen,
                  isLoading: isLoading,
                  icon: Icons.login,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Check Out',
                  onPressed: canPerformAction && !isLoading ? onCheckOut : null,
                  backgroundColor: AppColors.errorRed,
                  isLoading: isLoading,
                  icon: Icons.logout,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional info
          _buildInfoSection(distance, isWithinRange),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    String message;
    IconData icon;
    Color color;

    if (currentPosition == null) {
      message = 'Location not available. Please enable GPS and try again.';
      icon = Icons.location_off;
      color = AppColors.errorRed;
    } else {
      final distance = _calculateDistance();
      if (distance != null && distance > site.geofenceRadius) {
        message =
            'You are ${distance.toStringAsFixed(0)}m away from the site. Move closer to check in.';
        icon = Icons.near_me_disabled;
        color = AppColors.warningYellow;
      } else {
        message = 'Unable to determine your distance from the site.';
        icon = Icons.warning;
        color = AppColors.warningYellow;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(double? distance, bool isWithinRange) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Check-in Information',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Site',
            site.name,
          ),
          _buildInfoRow(
            'Required Range',
            '${site.geofenceRadius.toStringAsFixed(0)} meters',
          ),
          if (distance != null)
            _buildInfoRow(
              'Your Distance',
              '${distance.toStringAsFixed(0)} meters',
            ),
          _buildInfoRow(
            'Status',
            isWithinRange ? 'Within Range' : 'Out of Range',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            ': $value',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _canPerformAction() {
    if (currentPosition == null) return false;

    final distance = _calculateDistance();
    if (distance == null) return false;

    return distance <= site.geofenceRadius;
  }

  double? _calculateDistance() {
    if (currentPosition == null) return null;

    return Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      site.latitude,
      site.longitude,
    );
  }
}
