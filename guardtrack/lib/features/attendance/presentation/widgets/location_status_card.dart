import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class LocationStatusCard extends StatelessWidget {
  final Position? currentPosition;
  final double? locationAccuracy;
  final bool isLocationEnabled;
  final VoidCallback onRefreshLocation;

  const LocationStatusCard({
    super.key,
    this.currentPosition,
    this.locationAccuracy,
    required this.isLocationEnabled,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _getLocationStatusColor(),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Status',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefreshLocation,
                icon: const Icon(Icons.refresh),
                color: AppColors.primaryBlue,
                iconSize: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildStatusRow(
            'GPS Status',
            isLocationEnabled ? 'Enabled' : 'Disabled',
            isLocationEnabled ? AppColors.successGreen : AppColors.errorRed,
          ),
          
          const SizedBox(height: 8),
          
          _buildStatusRow(
            'Location',
            currentPosition != null ? 'Available' : 'Not Available',
            currentPosition != null ? AppColors.successGreen : AppColors.errorRed,
          ),
          
          if (currentPosition != null) ...[
            const SizedBox(height: 8),
            _buildStatusRow(
              'Accuracy',
              '${locationAccuracy?.toStringAsFixed(1) ?? 'Unknown'} meters',
              _getAccuracyColor(),
            ),
            
            const SizedBox(height: 8),
            _buildStatusRow(
              'Coordinates',
              '${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}',
              AppColors.textSecondary,
            ),
          ],
          
          if (!isLocationEnabled || currentPosition == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warningYellow.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.warningYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !isLocationEnabled
                          ? 'Please enable location services to check in'
                          : 'Unable to get current location. Please try again.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warningYellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getLocationStatusColor() {
    if (!isLocationEnabled) return AppColors.errorRed;
    if (currentPosition == null) return AppColors.warningYellow;
    return AppColors.successGreen;
  }

  Color _getAccuracyColor() {
    if (locationAccuracy == null) return AppColors.textSecondary;
    if (locationAccuracy! <= 10) return AppColors.successGreen;
    if (locationAccuracy! <= 50) return AppColors.warningYellow;
    return AppColors.errorRed;
  }
}
