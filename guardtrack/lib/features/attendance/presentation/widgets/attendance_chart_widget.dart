import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AttendanceChartWidget extends StatelessWidget {
  const AttendanceChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for the chart
    final List<AttendanceData> data = [
      AttendanceData('Mon', 8.5, true),
      AttendanceData('Tue', 9.0, true),
      AttendanceData('Wed', 0.0, false),
      AttendanceData('Thu', 8.2, true),
      AttendanceData('Fri', 9.5, true),
      AttendanceData('Sat', 8.8, true),
      AttendanceData('Sun', 0.0, false),
    ];

    return Container(
      height: 200,
      child: Column(
        children: [
          // Chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        Container(
                          height: item.isPresent ? (item.hours / 10) * 120 : 20,
                          decoration: BoxDecoration(
                            color: item.isPresent 
                                ? AppColors.primaryBlue 
                                : AppColors.errorRed.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Day label
                        Text(
                          item.day,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Present', AppColors.primaryBlue),
              const SizedBox(width: 16),
              _buildLegendItem('Absent', AppColors.errorRed.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class AttendanceData {
  final String day;
  final double hours;
  final bool isPresent;

  AttendanceData(this.day, this.hours, this.isPresent);
}
