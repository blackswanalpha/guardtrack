import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/attendance_service.dart';

class CheckInSuccessPage extends StatefulWidget {
  final AttendanceModel attendance;
  final SiteModel site;

  const CheckInSuccessPage({
    super.key,
    required this.attendance,
    required this.site,
  });

  @override
  State<CheckInSuccessPage> createState() => _CheckInSuccessPageState();
}

class _CheckInSuccessPageState extends State<CheckInSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _codeController;
  late AnimationController _detailsController;
  
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _codeAnimation;
  late Animation<double> _detailsAnimation;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _codeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );
    
    _codeAnimation = CurvedAnimation(
      parent: _codeController,
      curve: Curves.easeOutBack,
    );
    
    _detailsAnimation = CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOut,
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _checkmarkController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _codeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _detailsController.forward();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _codeController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCheckmarkIcon(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildSuccessMessage(),
                    const SizedBox(height: AppConstants.largePadding * 2),
                    _buildArrivalCode(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildAttendanceDetails(),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close,
            color: AppColors.white,
          ),
        ),
        const Spacer(),
        Text(
          'Check-in Complete',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.white,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48), // Balance the close button
      ],
    );
  }

  Widget _buildCheckmarkIcon() {
    return AnimatedBuilder(
      animation: _checkmarkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkmarkAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: AppColors.accentGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _detailsAnimation,
      child: Column(
        children: [
          Text(
            'Successfully Checked In!',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'at ${widget.site.name}',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCode() {
    return AnimatedBuilder(
      animation: _codeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _codeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Arrival Code',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                GestureDetector(
                  onTap: _copyCodeToClipboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _attendanceService.formatArrivalCode(widget.attendance.arrivalCode),
                          style: AppTextStyles.arrivalCode,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Icon(
                          Icons.copy,
                          size: 20,
                          color: AppColors.gray500,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Tap to copy',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceDetails() {
    return FadeTransition(
      opacity: _detailsAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Check-in Time',
              value: DateFormat('MMM dd, yyyy • HH:mm').format(widget.attendance.timestamp),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: '${widget.attendance.latitude.toStringAsFixed(6)}, ${widget.attendance.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildDetailRow(
              icon: Icons.speed,
              label: 'GPS Accuracy',
              value: '±${widget.attendance.accuracy.toStringAsFixed(1)}m',
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildDetailRow(
              icon: Icons.verified,
              label: 'Status',
              value: widget.attendance.status.name.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.white.withOpacity(0.8),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _detailsAnimation,
      child: Column(
        children: [
          CustomButton(
            text: 'Share Code',
            icon: Icons.share,
            onPressed: _shareCode,
            type: ButtonType.outline,
            backgroundColor: AppColors.white,
            textColor: AppColors.accentGreen,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomButton(
            text: 'Back to Dashboard',
            icon: Icons.dashboard,
            onPressed: _backToDashboard,
            backgroundColor: AppColors.white,
            textColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.attendance.arrivalCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Arrival code copied to clipboard'),
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.accentGreen,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _shareCode() {
    // TODO: Implement share functionality
    final message = 'Check-in Code: ${widget.attendance.arrivalCode}\n'
        'Site: ${widget.site.name}\n'
        'Time: ${DateFormat('MMM dd, yyyy • HH:mm').format(widget.attendance.timestamp)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon\n\nCode: $message'),
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _backToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
