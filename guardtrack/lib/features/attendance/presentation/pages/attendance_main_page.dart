import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/user_model.dart';
import 'attendance_history_page.dart';
import 'attendance_analysis_page.dart';
import 'assigned_sites_page.dart';

class AttendanceMainPage extends StatefulWidget {
  final UserModel user;

  const AttendanceMainPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceMainPage> createState() => _AttendanceMainPageState();
}

class _AttendanceMainPageState extends State<AttendanceMainPage>
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
        title: const Text('Attendance'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analysis',
            ),
            Tab(
              icon: Icon(Icons.location_city),
              text: 'Sites',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AttendanceHistoryPage(user: widget.user),
          AttendanceAnalysisPage(user: widget.user),
          AssignedSitesPage(user: widget.user),
        ],
      ),
    );
  }
}
