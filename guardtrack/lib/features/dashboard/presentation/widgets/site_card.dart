import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/location_service.dart';

class SiteCard extends StatelessWidget {
  final SiteModel site;
  final Position? currentPosition;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;

  const SiteCard({
    super.key,
    required this.site,
    this.currentPosition,
    this.onTap,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final isWithinRange = _isWithinRange(distance);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isWithinRange),
              const SizedBox(height: AppConstants.smallPadding),
              _buildAddress(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildLocationInfo(distance, isWithinRange),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildActions(isWithinRange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWithinRange) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                site.name,
                style: AppTextStyles.heading4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (site.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  site.description!,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        StatusBadge(
          status: isWithinRange ? StatusType.verified : StatusType.pending,
          customText: isWithinRange ? 'In Range' : 'Out of Range',
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.gray500,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            site.address,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(double? distance, bool isWithinRange) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: isWithinRange 
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.warningAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
        border: Border.all(
          color: isWithinRange 
              ? AppColors.accentGreen.withOpacity(0.3)
              : AppColors.warningAmber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWithinRange ? Icons.gps_fixed : Icons.gps_not_fixed,
            size: 16,
            color: isWithinRange ? AppColors.accentGreen : AppColors.warningAmber,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distance != null 
                      ? '${_formatDistance(distance)} away'
                      : 'Distance unknown',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isWithinRange ? AppColors.accentGreen : AppColors.warningDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Allowed radius: ${_formatDistance(site.allowedRadius)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isWithinRange) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'View Details',
            onPressed: onTap,
            type: ButtonType.outline,
            size: ButtonSize.small,
            icon: Icons.info_outline,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: CustomButton(
            text: 'Check In',
            onPressed: isWithinRange ? onCheckIn : null,
            type: ButtonType.primary,
            size: ButtonSize.small,
            icon: Icons.location_on,
          ),
        ),
      ],
    );
  }

  double? _calculateDistance() {
    if (currentPosition == null) return null;
    
    return LocationService().calculateDistance(
      currentPosition!.latitude,
      currentPosition!.longitude,
      site.latitude,
      site.longitude,
    );
  }

  bool _isWithinRange(double? distance) {
    if (distance == null) return false;
    return distance <= site.allowedRadius;
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }
}
