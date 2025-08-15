import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class LocationStatusWidget extends StatelessWidget {
  final Position? position;
  final VoidCallback? onLocationTap;

  const LocationStatusWidget({
    super.key,
    this.position,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onLocationTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildLocationInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location Status',
                style: AppTextStyles.labelMedium,
              ),
              Text(
                _getStatusText(),
                style: AppTextStyles.heading4.copyWith(
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.refresh,
          color: AppColors.gray400,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (position == null) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off,
              color: AppColors.gray500,
              size: 16,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Location not available',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.my_location,
          label: 'Coordinates',
          value:
              '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildInfoRow(
          icon: Icons.speed,
          label: 'Accuracy',
          value: '±${position!.accuracy.toStringAsFixed(1)}m',
          valueColor: _getAccuracyColor(),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildInfoRow(
          icon: Icons.access_time,
          label: 'Last Updated',
          value: _formatTimestamp(position!.timestamp),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildInfoRow(
          icon: Icons.terrain,
          label: 'Altitude',
          value: '${position!.altitude.toStringAsFixed(1)}m',
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.gray500,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor ?? AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (position == null) {
      return AppColors.errorRed;
    }

    if (position!.accuracy <= AppConstants.defaultLocationAccuracy) {
      return AppColors.accentGreen;
    } else {
      return AppColors.warningAmber;
    }
  }

  IconData _getStatusIcon() {
    if (position == null) {
      return Icons.location_off;
    }

    if (position!.accuracy <= AppConstants.defaultLocationAccuracy) {
      return Icons.gps_fixed;
    } else {
      return Icons.gps_not_fixed;
    }
  }

  String _getStatusText() {
    if (position == null) {
      return 'Not Available';
    }

    if (position!.accuracy <= AppConstants.defaultLocationAccuracy) {
      return 'Good Signal';
    } else {
      return 'Poor Signal';
    }
  }

  Color _getAccuracyColor() {
    if (position == null) return AppColors.errorRed;

    if (position!.accuracy <= 10) {
      return AppColors.accentGreen;
    } else if (position!.accuracy <= AppConstants.defaultLocationAccuracy) {
      return AppColors.warningAmber;
    } else {
      return AppColors.errorRed;
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }
}
