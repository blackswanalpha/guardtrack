import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/whatsapp_attendance_service.dart';
import '../../../../shared/services/demo_attendance_generator.dart';

class AttendanceWhatsAppPage extends StatefulWidget {
  final UserModel user;

  const AttendanceWhatsAppPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceWhatsAppPage> createState() => _AttendanceWhatsAppPageState();
}

class _AttendanceWhatsAppPageState extends State<AttendanceWhatsAppPage> {
  final WhatsAppAttendanceService _whatsappService =
      WhatsAppAttendanceService();

  bool _isLoading = false;
  List<SiteModel> _demoSites = [];
  List<UserModel> _demoEmployees = [];
  List<AttendanceModel> _todayAttendance = [];
  Map<String, dynamic> _attendanceStats = {};

  @override
  void initState() {
    super.initState();
    _generateDemoData();
  }

  void _generateDemoData() {
    setState(() => _isLoading = true);

    try {
      // Generate demo data
      _demoSites = DemoAttendanceGenerator.generateDemoSites();
      _demoEmployees = DemoAttendanceGenerator.generateDemoEmployees();

      // Assign employees to sites
      DemoAttendanceGenerator.assignEmployeesToSites(
          _demoEmployees, _demoSites);

      // Generate today's attendance
      _todayAttendance = DemoAttendanceGenerator.generateAttendanceForDate(
        date: DateTime.now(),
        employees: _demoEmployees,
        sites: _demoSites,
        attendanceRate: 0.85,
      );

      // Generate stats
      _attendanceStats = DemoAttendanceGenerator.generateAttendanceStats(
        attendanceRecords: _todayAttendance,
        employees: _demoEmployees,
        sites: _demoSites,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsOverview(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildQuickActions(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildSiteBreakdown(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildRecentCheckIns(),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Attendance WhatsApp Notifications'),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _generateDemoData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Today\'s Attendance Overview',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Employees',
                  '${_attendanceStats['totalEmployees'] ?? 0}',
                  Icons.people,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildStatCard(
                  'Active Sites',
                  '${_attendanceStats['totalSites'] ?? 0}',
                  Icons.location_on,
                  AppColors.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Check-ins',
                  '${_attendanceStats['totalCheckIns'] ?? 0}',
                  Icons.login,
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildStatCard(
                  'Check-outs',
                  '${_attendanceStats['totalCheckOuts'] ?? 0}',
                  Icons.logout,
                  AppColors.warningYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Attendance Rate: ${((_attendanceStats['attendanceRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'WhatsApp Notifications',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Daily Summary',
                  icon: Icons.summarize,
                  onPressed: _isLoading ? null : _sendDailySummary,
                  type: ButtonType.primary,
                  backgroundColor: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: CustomButton(
                  text: 'Missing Alerts',
                  icon: Icons.warning,
                  onPressed: _isLoading ? null : _sendMissingAlerts,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Bulk Check-ins',
                  icon: Icons.group,
                  onPressed: _isLoading ? null : _sendBulkNotifications,
                  type: ButtonType.primary,
                  backgroundColor: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: CustomButton(
                  text: 'Site Reports',
                  icon: Icons.location_city,
                  onPressed: _isLoading ? null : _sendSiteReports,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiteBreakdown() {
    final siteStats =
        _attendanceStats['siteStats'] as Map<String, Map<String, int>>? ?? {};

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Site Breakdown',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              itemCount: siteStats.length,
              itemBuilder: (context, index) {
                final entry = siteStats.entries.elementAt(index);
                final siteName = entry.key;
                final stats = entry.value;

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          siteName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${stats['checkIns']}↗️',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warningYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${stats['checkOuts']}↙️',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warningYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCheckIns() {
    final recentCheckIns = _todayAttendance.where((a) => a.isCheckIn).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Recent Check-ins',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              itemCount: recentCheckIns.take(10).length,
              itemBuilder: (context, index) {
                final attendance = recentCheckIns[index];
                final employee = _demoEmployees
                    .firstWhere((e) => e.id == attendance.guardId);
                final site =
                    _demoSites.firstWhere((s) => s.id == attendance.siteId);
                final timeStr =
                    DateFormat('HH:mm').format(attendance.timestamp);

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.successGreen.withOpacity(0.2),
                        child: Text(
                          employee.firstName[0],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.fullName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              site.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            attendance.arrivalCode,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers - placeholder methods
  Future<void> _sendDailySummary() async {
    setState(() => _isLoading = true);

    try {
      final success = await _whatsappService.sendDailyAttendanceSummary();
      _showResultSnackBar(
        success,
        'Daily attendance summary sent successfully!',
        'Failed to send daily summary',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMissingAlerts() async {
    setState(() => _isLoading = true);

    try {
      final success = await _whatsappService.sendMissingCheckInAlerts();
      _showResultSnackBar(
        success,
        'Missing check-in alerts sent successfully!',
        'Failed to send missing alerts',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendBulkNotifications() async {
    setState(() => _isLoading = true);

    try {
      final results = await _whatsappService.sendBulkCheckInNotifications(
        attendanceList: _todayAttendance.where((a) => a.isCheckIn).toList(),
      );

      final successCount = results.values.where((success) => success).length;
      final totalCount = results.length;

      _showResultSnackBar(
        successCount > 0,
        'Bulk notifications sent: $successCount/$totalCount successful',
        'Failed to send bulk notifications',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSiteReports() async {
    setState(() => _isLoading = true);

    try {
      int successCount = 0;
      for (final site in _demoSites.take(5)) {
        // Send for first 5 sites as demo
        final success =
            await _whatsappService.sendSiteAttendanceReport(siteId: site.id);
        if (success) successCount++;
      }

      _showResultSnackBar(
        successCount > 0,
        'Site reports sent: $successCount/5 successful',
        'Failed to send site reports',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResultSnackBar(
      bool success, String successMessage, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : errorMessage),
        backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
