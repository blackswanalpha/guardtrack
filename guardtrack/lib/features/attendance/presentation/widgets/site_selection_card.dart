import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/site_model.dart';

class SiteSelectionCard extends StatelessWidget {
  final SiteModel site;
  final Position? currentPosition;
  final bool isSelected;
  final VoidCallback onTap;

  const SiteSelectionCard({
    super.key,
    required this.site,
    this.currentPosition,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final isWithinRange = distance != null && distance <= site.geofenceRadius;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Distance and status indicators
            Row(
              children: [
                _buildStatusChip(
                  icon: Icons.location_on,
                  label: distance != null 
                      ? '${distance.toStringAsFixed(0)}m away'
                      : 'Distance unknown',
                  color: isWithinRange 
                      ? AppColors.successGreen 
                      : distance != null 
                          ? AppColors.warningYellow 
                          : AppColors.textSecondary,
                ),
                
                const SizedBox(width: 8),
                
                _buildStatusChip(
                  icon: isWithinRange ? Icons.check_circle : Icons.cancel,
                  label: isWithinRange ? 'In Range' : 'Out of Range',
                  color: isWithinRange ? AppColors.successGreen : AppColors.errorRed,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Site details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Shift Time',
                    '${site.shiftStartTime} - ${site.shiftEndTime}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Radius',
                    '${site.geofenceRadius.toStringAsFixed(0)}m',
                  ),
                ),
              ],
            ),
            
            if (site.specialInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        site.specialInstructions!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
