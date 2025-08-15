import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/user_model.dart';
import '../widgets/attendance_stats_card.dart';
import '../widgets/attendance_chart_widget.dart';

class AttendanceAnalysisPage extends StatefulWidget {
  final UserModel user;

  const AttendanceAnalysisPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceAnalysisPage> createState() => _AttendanceAnalysisPageState();
}

class _AttendanceAnalysisPageState extends State<AttendanceAnalysisPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last Month',
    'Last 3 Months',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              _buildPeriodSelector(),
              
              const SizedBox(height: 16),
              
              // Stats overview
              _buildStatsOverview(),
              
              const SizedBox(height: 16),
              
              // Attendance chart
              _buildAttendanceChart(),
              
              const SizedBox(height: 16),
              
              // Performance metrics
              _buildPerformanceMetrics(),
              
              const SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
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
            'Analysis Period',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryBlue 
                        : AppColors.backgroundGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primaryBlue 
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    period,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected 
                          ? Colors.white 
                          : AppColors.textSecondary,
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textDark,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: AttendanceStatsCard(
                title: 'Total Days',
                value: '22',
                subtitle: 'Working days',
                icon: Icons.calendar_today,
                color: AppColors.primaryBlue,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: AttendanceStatsCard(
                title: 'Present',
                value: '20',
                subtitle: '90.9% attendance',
                icon: Icons.check_circle,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: AttendanceStatsCard(
                title: 'Late Arrivals',
                value: '3',
                subtitle: '13.6% of days',
                icon: Icons.schedule,
                color: AppColors.warningYellow,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: AttendanceStatsCard(
                title: 'Absent',
                value: '2',
                subtitle: '9.1% of days',
                icon: Icons.cancel,
                color: AppColors.errorRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
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
            'Attendance Trend',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const AttendanceChartWidget(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
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
            'Performance Metrics',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildMetricRow(
            'Average Check-in Time',
            '08:15 AM',
            Icons.login,
            AppColors.primaryBlue,
          ),
          
          const SizedBox(height: 12),
          
          _buildMetricRow(
            'Average Check-out Time',
            '06:05 PM',
            Icons.logout,
            AppColors.primaryBlue,
          ),
          
          const SizedBox(height: 12),
          
          _buildMetricRow(
            'Average Hours per Day',
            '9.8 hours',
            Icons.access_time,
            AppColors.successGreen,
          ),
          
          const SizedBox(height: 12),
          
          _buildMetricRow(
            'Punctuality Score',
            '87%',
            Icons.star,
            AppColors.warningYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Refresh data here
      });
    }
  }
}
