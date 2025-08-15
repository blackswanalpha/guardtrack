import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Reports & Analytics',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: AppColors.white),
            onPressed: () {
              // Navigate to scheduled reports
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickReports(),
            const SizedBox(height: AppConstants.largePadding),
            _buildReportCategories(),
            const SizedBox(height: AppConstants.largePadding),
            _buildRecentReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Reports',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.defaultPadding,
          mainAxisSpacing: AppConstants.defaultPadding,
          childAspectRatio: 1.2,
          children: [
            _buildQuickReportCard(
              title: 'Daily Attendance',
              subtitle: 'Today\'s attendance summary',
              icon: Icons.today,
              color: AppColors.primaryBlue,
              onTap: () {
                // Generate daily report
              },
            ),
            _buildQuickReportCard(
              title: 'Weekly Summary',
              subtitle: 'This week\'s overview',
              icon: Icons.date_range,
              color: AppColors.accentGreen,
              onTap: () {
                // Generate weekly report
              },
            ),
            _buildQuickReportCard(
              title: 'Monthly Report',
              subtitle: 'Complete monthly analysis',
              icon: Icons.calendar_month,
              color: AppColors.warningAmber,
              onTap: () {
                // Generate monthly report
              },
            ),
            _buildQuickReportCard(
              title: 'Site Performance',
              subtitle: 'All sites performance',
              icon: Icons.analytics,
              color: Color(0xFF9C27B0),
              onTap: () {
                // Generate site performance report
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Categories',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildCategoryCard(
          title: 'Attendance Reports',
          description: 'Detailed attendance tracking and analysis',
          icon: Icons.access_time,
          color: AppColors.primaryBlue,
          reports: ['Daily Attendance', 'Late Arrivals', 'Absence Tracking', 'Overtime Reports'],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildCategoryCard(
          title: 'Employee Reports',
          description: 'Employee performance and management reports',
          icon: Icons.people,
          color: AppColors.accentGreen,
          reports: ['Performance Reviews', 'Training Records', 'Payroll Reports', 'Employee Analytics'],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildCategoryCard(
          title: 'Site Reports',
          description: 'Site-specific analysis and coverage reports',
          icon: Icons.location_on,
          color: AppColors.warningAmber,
          reports: ['Site Coverage', 'Incident Reports', 'Security Logs', 'Maintenance Records'],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> reports,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: reports.map((report) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomButton(
            text: 'Generate Reports',
            onPressed: () {
              // Navigate to report generation
            },
            type: ButtonType.outline,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: AppTextStyles.heading3,
            ),
            TextButton(
              onPressed: () {
                // View all reports
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            final reportTypes = ['Daily Attendance', 'Weekly Summary', 'Site Performance', 'Employee Analytics', 'Monthly Report'];
            final dates = ['Today', 'Yesterday', '2 days ago', '3 days ago', '1 week ago'];
            
            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              child: ListTile(
                leading: const Icon(Icons.description, color: AppColors.primaryBlue),
                title: Text(reportTypes[index]),
                subtitle: Text('Generated: ${dates[index]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, size: 20),
                      onPressed: () {
                        // Download report
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                        // Share report
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
