import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Attendance Management',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.white),
            onPressed: () {
              // Navigate to live map view
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'History'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildHistoryView(),
          _buildAlertsView(),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Current Attendance',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Attendance History',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'View historical attendance records',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber,
            size: 64,
            color: AppColors.warningAmber,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Attendance Alerts',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Monitor late arrivals and absences',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Present Today',
            value: '142',
            total: '156',
            color: AppColors.accentGreen,
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildStatCard(
            title: 'Late Arrivals',
            value: '8',
            total: '156',
            color: AppColors.warningAmber,
            icon: Icons.access_time,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildStatCard(
            title: 'Absent',
            value: '6',
            total: '156',
            color: AppColors.errorRed,
            icon: Icons.cancel,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String total,
    required Color color,
    required IconData icon,
  }) {
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          Text(
            '/ $total',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        final statuses = ['Present', 'Late', 'Absent'];
        final colors = [
          AppColors.accentGreen,
          AppColors.warningAmber,
          AppColors.errorRed
        ];
        final status = statuses[index % 3];
        final color = colors[index % 3];

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                status == 'Present'
                    ? Icons.check
                    : status == 'Late'
                        ? Icons.access_time
                        : Icons.cancel,
                color: color,
                size: 20,
              ),
            ),
            title: Text('Employee ${index + 1}'),
            subtitle: Text(
                'Site Alpha • Check-in: ${status == 'Absent' ? 'No check-in' : '08:${(index * 5).toString().padLeft(2, '0')}'}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}
