import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/attendance_service.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;
  final SiteModel? site;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.attendance,
    this.site,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceService = AttendanceService();
    
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
              _buildHeader(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSiteInfo(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAttendanceDetails(attendanceService),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildFooter(),
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
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            attendance.isCheckIn ? Icons.login : Icons.logout,
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attendance.isCheckIn ? 'Check In' : 'Check Out',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(attendance.timestamp),
                style: AppTextStyles.heading4,
              ),
            ],
          ),
        ),
        StatusBadge(
          status: _getStatusBadgeType(),
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildSiteInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 16,
            color: AppColors.gray500,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              site?.name ?? 'Unknown Site',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (site?.address != null) ...[
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: Text(
                site!.address,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceDetails(AttendanceService attendanceService) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            icon: Icons.qr_code,
            label: 'Code',
            value: attendanceService.formatArrivalCode(attendance.arrivalCode),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildDetailItem(
            icon: Icons.speed,
            label: 'Accuracy',
            value: '±${attendance.accuracy.toStringAsFixed(1)}m',
          ),
        ),
        if (attendance.photoUrl != null) ...[
          const SizedBox(width: AppConstants.defaultPadding),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: AppColors.accentGreen,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.gray500,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.my_location,
          size: 14,
          color: AppColors.gray400,
        ),
        const SizedBox(width: 4),
        Text(
          '${attendance.latitude.toStringAsFixed(6)}, ${attendance.longitude.toStringAsFixed(6)}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray500,
          ),
        ),
        const Spacer(),
        if (attendance.verifiedAt != null) ...[
          Icon(
            Icons.verified,
            size: 14,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified ${DateFormat('MMM dd').format(attendance.verifiedAt!)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentGreen,
            ),
          ),
        ] else if (attendance.isPending) ...[
          Icon(
            Icons.pending,
            size: 14,
            color: AppColors.warningAmber,
          ),
          const SizedBox(width: 4),
          Text(
            'Pending Review',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.warningAmber,
            ),
          ),
        ],
      ],
    );
  }

  Color _getTypeColor() {
    return attendance.isCheckIn ? AppColors.accentGreen : AppColors.primaryBlue;
  }

  StatusType _getStatusBadgeType() {
    switch (attendance.status) {
      case AttendanceStatus.verified:
        return StatusType.verified;
      case AttendanceStatus.pending:
        return StatusType.pending;
      case AttendanceStatus.rejected:
        return StatusType.rejected;
    }
  }
}
