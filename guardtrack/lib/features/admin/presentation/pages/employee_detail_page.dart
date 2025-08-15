import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/site_model.dart';

class EmployeeDetailPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDetailPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock employee data
  late UserModel _employee;
  late List<AttendanceModel> _attendanceRecords;
  late List<SiteModel> _assignedSites;
  late List<Map<String, dynamic>> _siteHistory;

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEmployeeData();
    _loadAttendanceData();
    _loadSiteData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEmployeeData() {
    // Mock employee data
    _employee = UserModel(
      id: widget.employeeId,
      email:
          '${widget.employeeName.toLowerCase().replaceAll(' ', '.')}@company.com',
      firstName: widget.employeeName.split(' ').first,
      lastName: widget.employeeName.split(' ').length > 1
          ? widget.employeeName.split(' ').last
          : '',
      role: UserRole.guard,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      phone: '+1234567890',
      assignedSiteIds: ['site1', 'site2'],
    );
  }

  void _loadAttendanceData() {
    // Mock attendance records for the past 30 days
    _attendanceRecords = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final shouldHaveRecord =
          !isWeekend && index < 25; // Skip some days for variety

      if (!shouldHaveRecord) return null;

      final checkInTime = DateTime(
          date.year, date.month, date.day, 8 + (index % 3), (index * 15) % 60);
      final checkOutTime = checkInTime
          .add(Duration(hours: 8 + (index % 2), minutes: (index * 10) % 60));

      return AttendanceModel(
        id: 'att_${index}',
        guardId: widget.employeeId,
        siteId: ['site1', 'site2'][index % 2],
        type: AttendanceType.checkIn,
        status: AttendanceStatus.verified,
        arrivalCode: 'ARR${1000 + index}',
        latitude: -1.2921 + (index * 0.001),
        longitude: 36.8219 + (index * 0.001),
        accuracy: 5.0 + (index % 10),
        timestamp: checkInTime,
        photoUrl:
            index % 5 == 0 ? 'https://example.com/photo_$index.jpg' : null,
        notes: index % 7 == 0 ? 'All clear, no incidents reported' : null,
        createdAt: checkInTime,
      );
    }).where((record) => record != null).cast<AttendanceModel>().toList();
  }

  void _loadSiteData() {
    // Mock assigned sites
    _assignedSites = [
      SiteModel(
        id: 'site1',
        name: 'Corporate Plaza Alpha',
        address: '123 Business District, Nairobi',
        latitude: -1.2921,
        longitude: 36.8219,
        allowedRadius: 50.0,
        isActive: true,
        description: 'Main corporate building with 24/7 security coverage',
        contactPerson: 'John Manager',
        contactPhone: '+254700123456',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        assignedGuardIds: [widget.employeeId],
        shiftStartTime: '08:00',
        shiftEndTime: '17:00',
      ),
      SiteModel(
        id: 'site2',
        name: 'Warehouse Beta',
        address: '456 Industrial Area, Nairobi',
        latitude: -1.3032,
        longitude: 36.8441,
        allowedRadius: 75.0,
        isActive: true,
        description: 'Storage facility requiring periodic security checks',
        contactPerson: 'Jane Supervisor',
        contactPhone: '+254700654321',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        assignedGuardIds: [widget.employeeId],
        shiftStartTime: '18:00',
        shiftEndTime: '06:00',
      ),
    ];

    // Mock site history
    _siteHistory = [
      {
        'site': _assignedSites[0],
        'assignedDate': DateTime.now().subtract(const Duration(days: 180)),
        'unassignedDate': null,
        'status': 'Active',
        'totalHours': 1440.0, // 180 days * 8 hours
        'attendanceRate': 94.2,
        'incidentCount': 2,
        'performanceScore': 4.8,
      },
      {
        'site': _assignedSites[1],
        'assignedDate': DateTime.now().subtract(const Duration(days: 90)),
        'unassignedDate': null,
        'status': 'Active',
        'totalHours': 720.0, // 90 days * 8 hours
        'attendanceRate': 96.7,
        'incidentCount': 0,
        'performanceScore': 4.9,
      },
      {
        'site': SiteModel(
          id: 'site3',
          name: 'Shopping Mall Gamma',
          address: '789 Commercial Street, Nairobi',
          latitude: -1.2845,
          longitude: 36.8173,
          allowedRadius: 100.0,
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 400)),
        ),
        'assignedDate': DateTime.now().subtract(const Duration(days: 365)),
        'unassignedDate': DateTime.now().subtract(const Duration(days: 200)),
        'status': 'Completed',
        'totalHours': 1320.0, // 165 days * 8 hours
        'attendanceRate': 91.5,
        'incidentCount': 5,
        'performanceScore': 4.3,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildEmployeeHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeeDetailsTab(),
                _buildAttendanceRecordsTab(),
                _buildSiteAssignmentStatusTab(),
                _buildSiteHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: Text(
        'Employee Details',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.white),
          onPressed: _editEmployee,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
            const PopupMenuItem(
                value: 'reset_password', child: Text('Reset Password')),
            const PopupMenuItem(
                value: 'send_notification', child: Text('Send Notification')),
            const PopupMenuItem(
                value: 'export_data', child: Text('Export Data')),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              '${_employee.firstName[0]}${_employee.lastName.isNotEmpty ? _employee.lastName[0] : ''}',
              style: AppTextStyles.heading2.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _employee.fullName,
                  style: AppTextStyles.heading3,
                ),
                Text(
                  _employee.email,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.gray600),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _employee.isActive
                            ? AppColors.accentGreen.withOpacity(0.1)
                            : AppColors.gray400.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _employee.isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _employee.isActive
                              ? AppColors.accentGreen
                              : AppColors.gray600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _employee.role.name.toUpperCase(),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.gray600,
        indicatorColor: AppColors.primaryBlue,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Attendance'),
          Tab(text: 'Assignments'),
          Tab(text: 'Site History'),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage: _employee.profileImageUrl != null
                      ? NetworkImage(_employee.profileImageUrl!)
                      : null,
                  child: _employee.profileImageUrl == null
                      ? Text(
                          '${_employee.firstName[0]}${_employee.lastName.isNotEmpty ? _employee.lastName[0] : ''}',
                          style: AppTextStyles.heading1
                              .copyWith(color: AppColors.white),
                        )
                      : null,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  _employee.fullName,
                  style: AppTextStyles.heading2,
                ),
                Text(
                  _employee.role.name.toUpperCase(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),

          _buildInfoCard(
            title: 'Personal Information',
            children: [
              _buildInfoRow('Full Name', _employee.fullName),
              _buildInfoRow('Email', _employee.email),
              _buildInfoRow('Phone', _employee.phone ?? 'Not provided'),
              _buildInfoRow('Employee ID', _employee.id),
              _buildInfoRow('Join Date', _formatDate(_employee.createdAt)),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          _buildInfoCard(
            title: 'Employment Status',
            children: [
              _buildInfoRow('Role', _employee.role.name.toUpperCase()),
              _buildInfoRow(
                  'Status', _employee.isActive ? 'Active' : 'Inactive'),
              _buildInfoRow('Department', 'Security Operations'),
              _buildInfoRow('Employment Type', 'Full-time'),
              _buildInfoRow('Supervisor', 'John Manager'),
              _buildInfoRow('Assigned Sites',
                  '${_employee.assignedSiteIds?.length ?? 0} sites'),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          _buildInfoCard(
            title: 'Contact Details',
            children: [
              _buildInfoRow('Primary Email', _employee.email),
              _buildInfoRow('Phone Number', _employee.phone ?? 'Not provided'),
              _buildInfoRow('Emergency Contact', '+254700987654'),
              _buildInfoRow('Address', '123 Residential Area, Nairobi'),
              _buildInfoRow('Next of Kin', 'Jane Doe (Spouse)'),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          _buildInfoCard(
            title: 'Performance Overview',
            children: [
              _buildInfoRow('Attendance Rate', '94.2%'),
              _buildInfoRow('On-time Rate', '89.5%'),
              _buildInfoRow('Total Check-ins', '1,247'),
              _buildInfoRow('Last Check-in', '2 hours ago'),
              _buildInfoRow('Performance Score', '4.8/5.0'),
              _buildInfoRow('Incidents Reported', '12'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter Section
          _buildDateFilterSection(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Attendance Statistics
          _buildAttendanceStatsRow(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Total Hours Summary
          _buildHoursSummaryCard(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Filter Buttons
          _buildFilterButtons(),
          const SizedBox(height: AppConstants.defaultPadding),

          Text('Attendance Records', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),

          // Enhanced Attendance List
          _buildEnhancedAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildSiteAssignmentStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Assignments Overview
          _buildCurrentAssignmentsOverview(),
          const SizedBox(height: AppConstants.defaultPadding),

          Text('Current Site Assignments', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCurrentSiteAssignments(),

          const SizedBox(height: AppConstants.largePadding),
          Text('Assignment History', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAssignmentHistory(),
        ],
      ),
    );
  }

  Widget _buildSiteHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Site History Overview
          _buildSiteHistoryOverview(),
          const SizedBox(height: AppConstants.defaultPadding),

          Text('Complete Site Assignment History',
              style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSiteHistoryList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
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
          Text(title, style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Present', '22', AppColors.accentGreen)),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(child: _buildStatCard('Late', '3', AppColors.warningAmber)),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(child: _buildStatCard('Absent', '2', AppColors.errorRed)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
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
          Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
          Text(title,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(Duration(days: index));
        final status = index % 3 == 0
            ? 'Present'
            : index % 3 == 1
                ? 'Late'
                : 'Absent';
        final color = status == 'Present'
            ? AppColors.accentGreen
            : status == 'Late'
                ? AppColors.warningAmber
                : AppColors.errorRed;

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: Icon(
              status == 'Present'
                  ? Icons.check_circle
                  : status == 'Late'
                      ? Icons.access_time
                      : Icons.cancel,
              color: color,
            ),
            title: Text(_formatDate(date)),
            subtitle: Text(
                'Site Alpha • ${status == 'Absent' ? 'No check-in' : '08:${(index * 15).toString().padLeft(2, '0')}'}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(status,
                  style: AppTextStyles.bodySmall.copyWith(color: color)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        final assignments = [
          'Night Patrol - Site Alpha',
          'Security Check - Site Beta',
          'Access Control - Main Gate'
        ];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: const Icon(Icons.assignment, color: AppColors.primaryBlue),
            title: Text(assignments[index]),
            subtitle: Text(
                'Active • Due: ${_formatDate(DateTime.now().add(Duration(days: index + 1)))}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        final activities = [
          'Checked in at Site Alpha',
          'Completed security patrol',
          'Updated profile information',
          'Assigned to new site',
          'Password changed'
        ];
        final times = [
          '2 hours ago',
          '4 hours ago',
          '1 day ago',
          '3 days ago',
          '1 week ago'
        ];

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: const Icon(Icons.history, color: AppColors.gray600),
            title: Text(activities[index]),
            subtitle: Text(times[index]),
          ),
        );
      },
    );
  }

  // Enhanced Attendance Tab Methods
  Widget _buildDateFilterSection() {
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
          Text('Filter by Date Range', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray600)),
                        Text(
                            _startDate != null
                                ? _formatDate(_startDate!)
                                : 'Select date',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray600)),
                        Text(
                            _endDate != null
                                ? _formatDate(_endDate!)
                                : 'Select date',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatsRow() {
    final filteredRecords = _getFilteredAttendanceRecords();
    final totalDays = filteredRecords.length;
    final presentDays = filteredRecords
        .where((r) => r.status == AttendanceStatus.verified)
        .length;
    final lateDays = filteredRecords.where((r) => r.timestamp.hour > 8).length;
    final absentDays = 30 - totalDays; // Assuming 30 working days in period

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Present', '$presentDays', AppColors.accentGreen)),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
            child: _buildStatCard('Late', '$lateDays', AppColors.warningAmber)),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
            child: _buildStatCard('Absent', '$absentDays', AppColors.errorRed)),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
            child: _buildStatCard(
                'Rate',
                '${((presentDays / 30) * 100).toStringAsFixed(1)}%',
                AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildHoursSummaryCard() {
    final filteredRecords = _getFilteredAttendanceRecords();
    final totalHours = filteredRecords.length * 8.0; // Assuming 8 hours per day
    final avgHoursPerDay =
        filteredRecords.isNotEmpty ? totalHours / filteredRecords.length : 0.0;

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
          Text('Hours Summary', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${totalHours.toStringAsFixed(1)}',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.primaryBlue)),
                  Text('Total Hours',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              Column(
                children: [
                  Text('${avgHoursPerDay.toStringAsFixed(1)}',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.accentGreen)),
                  Text('Avg/Day',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              Column(
                children: [
                  Text('${(totalHours / 40).toStringAsFixed(1)}',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.warningAmber)),
                  Text('Weeks',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        _buildFilterChip('All', _selectedFilter == 'All'),
        const SizedBox(width: AppConstants.smallPadding),
        _buildFilterChip('Present', _selectedFilter == 'Present'),
        const SizedBox(width: AppConstants.smallPadding),
        _buildFilterChip('Late', _selectedFilter == 'Late'),
        const SizedBox(width: AppConstants.smallPadding),
        _buildFilterChip('Absent', _selectedFilter == 'Absent'),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAttendanceList() {
    final filteredRecords = _getFilteredAttendanceRecords();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        final site = _assignedSites.firstWhere((s) => s.id == record.siteId,
            orElse: () => _assignedSites.first);
        final isLate = record.timestamp.hour > 8;
        final status = isLate ? 'Late' : 'Present';
        final color = isLate ? AppColors.warningAmber : AppColors.accentGreen;

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ExpansionTile(
            leading: Icon(
              isLate ? Icons.access_time : Icons.check_circle,
              color: color,
            ),
            title: Text(_formatDate(record.timestamp)),
            subtitle: Text('${site.name} • ${_formatTime(record.timestamp)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(status,
                  style: AppTextStyles.bodySmall.copyWith(color: color)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Arrival Code', record.arrivalCode),
                    _buildInfoRow('Location Accuracy',
                        '${record.accuracy.toStringAsFixed(1)}m'),
                    if (record.notes != null)
                      _buildInfoRow('Notes', record.notes!),
                    if (record.photoUrl != null)
                      Row(
                        children: [
                          Text('Photo: ',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.gray600)),
                          GestureDetector(
                            onTap: () => _showPhotoDialog(record.photoUrl!),
                            child: Text('View Photo',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.primaryBlue)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<AttendanceModel> _getFilteredAttendanceRecords() {
    var filtered = _attendanceRecords.where((record) {
      if (_startDate != null && record.timestamp.isBefore(_startDate!))
        return false;
      if (_endDate != null && record.timestamp.isAfter(_endDate!)) return false;

      if (_selectedFilter == 'Present') return record.timestamp.hour <= 8;
      if (_selectedFilter == 'Late') return record.timestamp.hour > 8;
      if (_selectedFilter == 'Absent')
        return false; // Absent records don't exist in attendance list

      return true;
    }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _showPhotoDialog(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(photoUrl,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 100)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _editEmployee() {
    // Navigate to edit employee page
    Navigator.pushNamed(context, '/admin/employee/edit', arguments: _employee);
  }

  // Site Assignment Status Tab Methods
  Widget _buildCurrentAssignmentsOverview() {
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
          Text('Assignment Overview', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${_assignedSites.length}',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.primaryBlue)),
                  Text('Active Sites',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              Column(
                children: [
                  Text('180',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.accentGreen)),
                  Text('Days Assigned',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              Column(
                children: [
                  Text('96.7%',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.warningAmber)),
                  Text('Avg Performance',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSiteAssignments() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _assignedSites.length,
      itemBuilder: (context, index) {
        final site = _assignedSites[index];
        final assignmentData =
            _siteHistory.firstWhere((h) => h['site'].id == site.id);

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text('${index + 1}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white)),
            ),
            title: Text(site.name, style: AppTextStyles.heading4),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(site.address,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Active',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.accentGreen)),
                    ),
                    const SizedBox(width: 8),
                    Text('${site.shiftStartTime} - ${site.shiftEndTime}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Assigned Date',
                        _formatDate(assignmentData['assignedDate'])),
                    _buildInfoRow(
                        'Total Hours', '${assignmentData['totalHours']} hrs'),
                    _buildInfoRow('Attendance Rate',
                        '${assignmentData['attendanceRate']}%'),
                    _buildInfoRow('Performance Score',
                        '${assignmentData['performanceScore']}/5.0'),
                    _buildInfoRow(
                        'Incidents', '${assignmentData['incidentCount']}'),
                    _buildInfoRow(
                        'Contact Person', site.contactPerson ?? 'N/A'),
                    _buildInfoRow('Contact Phone', site.contactPhone ?? 'N/A'),
                    const SizedBox(height: AppConstants.smallPadding),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewSiteDetails(site),
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('View Site'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewAssignmentHistory(site),
                            icon: const Icon(Icons.history, size: 16),
                            label: const Text('History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gray500,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentHistory() {
    final allAssignments = _siteHistory.expand((history) {
      return [
        {
          'type': 'assignment',
          'date': history['assignedDate'],
          'site': history['site'],
          'action': 'Assigned to ${history['site'].name}',
          'status': 'assigned',
        },
        if (history['unassignedDate'] != null)
          {
            'type': 'unassignment',
            'date': history['unassignedDate'],
            'site': history['site'],
            'action': 'Unassigned from ${history['site'].name}',
            'status': 'unassigned',
          },
      ];
    }).toList();

    allAssignments.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allAssignments.length,
      itemBuilder: (context, index) {
        final assignment = allAssignments[index];
        final isAssignment = assignment['status'] == 'assigned';

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: Icon(
              isAssignment ? Icons.add_location : Icons.remove_circle_outline,
              color: isAssignment ? AppColors.accentGreen : AppColors.errorRed,
            ),
            title: Text(assignment['action'] as String),
            subtitle: Text(_formatDate(assignment['date'] as DateTime)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isAssignment ? AppColors.accentGreen : AppColors.errorRed)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAssignment ? 'Assigned' : 'Unassigned',
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      isAssignment ? AppColors.accentGreen : AppColors.errorRed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewSiteDetails(SiteModel site) {
    Navigator.pushNamed(context, '/admin/site/detail',
        arguments: {'siteId': site.id, 'siteName': site.name});
  }

  void _viewAssignmentHistory(SiteModel site) {
    // Show detailed assignment history for this specific site
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${site.name} - Assignment History',
                  style: AppTextStyles.heading3),
              const SizedBox(height: AppConstants.defaultPadding),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Add detailed history for this specific site
                    Text('Detailed assignment history would be shown here...'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'deactivate':
        _showDeactivateDialog();
        break;
      case 'reset_password':
        _resetPassword();
        break;
      case 'send_notification':
        _sendNotification();
        break;
      case 'export_data':
        _exportData();
        break;
    }
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Employee'),
        content:
            Text('Are you sure you want to deactivate ${_employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Deactivate',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement deactivation
            },
            type: ButtonType.text,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _resetPassword() {
    // TODO: Implement password reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')),
    );
  }

  void _sendNotification() {
    // TODO: Navigate to send notification
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Employee data exported')),
    );
  }

  // Site History Tab Methods
  Widget _buildSiteHistoryOverview() {
    final totalSites = _siteHistory.length;
    final activeSites =
        _siteHistory.where((h) => h['status'] == 'Active').length;
    final completedSites =
        _siteHistory.where((h) => h['status'] == 'Completed').length;
    final totalHours = _siteHistory.fold<double>(
        0.0, (sum, h) => sum + (h['totalHours'] as double));
    final avgPerformance = _siteHistory.fold<double>(
            0.0, (sum, h) => sum + (h['performanceScore'] as double)) /
        totalSites;

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
          Text('Site History Summary', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('$totalSites',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.primaryBlue)),
                    Text('Total Sites',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$activeSites',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.accentGreen)),
                    Text('Active',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$completedSites',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.warningAmber)),
                    Text('Completed',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('${totalHours.toStringAsFixed(0)}',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.primaryBlue)),
                    Text('Total Hours',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${avgPerformance.toStringAsFixed(1)}/5.0',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.accentGreen)),
                    Text('Avg Performance',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiteHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _siteHistory.length,
      itemBuilder: (context, index) {
        final history = _siteHistory[index];
        final site = history['site'] as SiteModel;
        final isActive = history['status'] == 'Active';
        final statusColor =
            isActive ? AppColors.accentGreen : AppColors.gray500;

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(
                isActive ? Icons.location_on : Icons.history,
                color: AppColors.white,
                size: 20,
              ),
            ),
            title: Text(site.name, style: AppTextStyles.heading4),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(site.address,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        history['status'] as String,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: statusColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(history['assignedDate'])} - ${history['unassignedDate'] != null ? _formatDate(history['unassignedDate']) : 'Present'}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assignment Details', style: AppTextStyles.heading4),
                    const SizedBox(height: AppConstants.smallPadding),
                    _buildInfoRow(
                        'Duration',
                        _calculateDuration(history['assignedDate'],
                            history['unassignedDate'])),
                    _buildInfoRow(
                        'Total Hours Worked', '${history['totalHours']} hrs'),
                    _buildInfoRow(
                        'Attendance Rate', '${history['attendanceRate']}%'),
                    _buildInfoRow('Performance Score',
                        '${history['performanceScore']}/5.0'),
                    _buildInfoRow(
                        'Incidents Reported', '${history['incidentCount']}'),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text('Performance Metrics', style: AppTextStyles.heading4),
                    const SizedBox(height: AppConstants.smallPadding),
                    _buildPerformanceMetrics(history),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewSiteDetails(site),
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('View Site'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: AppConstants.smallPadding),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _viewCurrentAssignment(site),
                              icon: const Icon(Icons.assignment, size: 16),
                              label: const Text('Current'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                foregroundColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> history) {
    final attendanceRate = history['attendanceRate'] as double;
    final performanceScore = history['performanceScore'] as double;
    final incidentCount = history['incidentCount'] as int;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color:
                  _getPerformanceColor(attendanceRate / 100).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text('$attendanceRate%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getPerformanceColor(attendanceRate / 100),
                      fontWeight: FontWeight.bold,
                    )),
                Text('Attendance',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color:
                  _getPerformanceColor(performanceScore / 5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text('${performanceScore.toStringAsFixed(1)}/5',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getPerformanceColor(performanceScore / 5),
                      fontWeight: FontWeight.bold,
                    )),
                Text('Performance',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: _getIncidentColor(incidentCount).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text('$incidentCount',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getIncidentColor(incidentCount),
                      fontWeight: FontWeight.bold,
                    )),
                Text('Incidents',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDuration(DateTime start, DateTime? end) {
    final endDate = end ?? DateTime.now();
    final difference = endDate.difference(start);
    final days = difference.inDays;

    if (days < 30) {
      return '$days days';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      return '$years year${years > 1 ? 's' : ''} ${remainingMonths > 0 ? '$remainingMonths month${remainingMonths > 1 ? 's' : ''}' : ''}';
    }
  }

  Color _getPerformanceColor(double ratio) {
    if (ratio >= 0.9) return AppColors.accentGreen;
    if (ratio >= 0.7) return AppColors.warningAmber;
    return AppColors.errorRed;
  }

  Color _getIncidentColor(int count) {
    if (count == 0) return AppColors.accentGreen;
    if (count <= 2) return AppColors.warningAmber;
    return AppColors.errorRed;
  }

  void _viewCurrentAssignment(SiteModel site) {
    Navigator.pushNamed(context, '/admin/assignment/current', arguments: {
      'employeeId': widget.employeeId,
      'siteId': site.id,
    });
  }
}
