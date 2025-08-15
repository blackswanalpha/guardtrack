import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/user_model.dart';
import 'admin_dashboard_page.dart';
import '../../../admin/presentation/pages/employee_management_page.dart';
import '../../../admin/presentation/pages/attendance_management_page.dart';
import '../../../admin/presentation/pages/site_management_page.dart';
import '../../../admin/presentation/pages/reports_page.dart';

class AdminMainNavigationPage extends StatefulWidget {
  final UserModel user;

  const AdminMainNavigationPage({
    super.key,
    required this.user,
  });

  @override
  State<AdminMainNavigationPage> createState() =>
      _AdminMainNavigationPageState();
}

class _AdminMainNavigationPageState extends State<AdminMainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    _pages = [
      const AdminDashboardPage(),
      const EmployeeManagementPage(),
      const AttendanceManagementPage(),
      const SiteManagementPage(),
      const ReportsPage(),
    ];

    _navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Employees',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.access_time_outlined),
        activeIcon: Icon(Icons.access_time),
        label: 'Attendance',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.location_on_outlined),
        activeIcon: Icon(Icons.location_on),
        label: 'Sites',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment_outlined),
        activeIcon: Icon(Icons.assessment),
        label: 'Reports',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.gray500,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        items: _navItems,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
