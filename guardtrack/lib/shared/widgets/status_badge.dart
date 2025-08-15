import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

enum StatusType { verified, pending, rejected, offline }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customText;
  final double? fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: fontSize ?? 12,
            color: config.iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            customText ?? config.text,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.textColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case StatusType.verified:
        return _StatusConfig(
          text: 'Verified',
          backgroundColor: AppColors.accentGreen.withOpacity(0.1),
          borderColor: AppColors.accentGreen.withOpacity(0.3),
          textColor: AppColors.accentGreen,
          iconColor: AppColors.accentGreen,
          icon: Icons.check_circle,
        );
      case StatusType.pending:
        return _StatusConfig(
          text: 'Pending',
          backgroundColor: AppColors.warningAmber.withOpacity(0.1),
          borderColor: AppColors.warningAmber.withOpacity(0.3),
          textColor: AppColors.warningDark,
          iconColor: AppColors.warningAmber,
          icon: Icons.access_time,
        );
      case StatusType.rejected:
        return _StatusConfig(
          text: 'Rejected',
          backgroundColor: AppColors.errorRed.withOpacity(0.1),
          borderColor: AppColors.errorRed.withOpacity(0.3),
          textColor: AppColors.errorRed,
          iconColor: AppColors.errorRed,
          icon: Icons.cancel,
        );
      case StatusType.offline:
        return _StatusConfig(
          text: 'Offline',
          backgroundColor: AppColors.gray500.withOpacity(0.1),
          borderColor: AppColors.gray500.withOpacity(0.3),
          textColor: AppColors.gray700,
          iconColor: AppColors.gray500,
          icon: Icons.cloud_off,
        );
    }
  }
}

class _StatusConfig {
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const _StatusConfig({
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}
