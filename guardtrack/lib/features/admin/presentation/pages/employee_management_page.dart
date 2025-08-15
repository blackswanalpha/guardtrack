import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import 'employee_detail_page.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveEmployeesList(),
                _buildInactiveEmployeesList(),
                _buildEmployeeAnalytics(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "employee_management_fab",
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: Text(
        'Employee Management',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.upload_file, color: AppColors.white),
          onPressed: _showBulkImportDialog,
          tooltip: 'Bulk Import',
        ),
        IconButton(
          icon: const Icon(Icons.download, color: AppColors.white),
          onPressed: _exportEmployeeData,
          tooltip: 'Export Data',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
            onChanged: _onSearchChanged,
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
          Tab(text: 'Active (142)'),
          Tab(text: 'Inactive (14)'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildActiveEmployeesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 10, // Mock data
      itemBuilder: (context, index) {
        return _buildEmployeeCard(
          name: 'Employee ${index + 1}',
          email: 'employee${index + 1}@company.com',
          role: index % 3 == 0 ? 'Supervisor' : 'Guard',
          sites: ['Site Alpha', 'Site Beta'],
          status: 'Active',
          lastSeen: '2 hours ago',
          isActive: true,
        );
      },
    );
  }

  Widget _buildInactiveEmployeesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 5, // Mock data
      itemBuilder: (context, index) {
        return _buildEmployeeCard(
          name: 'Former Employee ${index + 1}',
          email: 'former${index + 1}@company.com',
          role: 'Guard',
          sites: ['Site Gamma'],
          status: 'Inactive',
          lastSeen: '2 weeks ago',
          isActive: false,
        );
      },
    );
  }

  Widget _buildEmployeeAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employee Analytics',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard(
            title: 'Total Employees',
            value: '156',
            subtitle: '+12 this month',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard(
            title: 'Average Attendance',
            value: '94.2%',
            subtitle: '+2.1% vs last month',
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard(
            title: 'Top Performer',
            value: 'Sarah Johnson',
            subtitle: '99.8% attendance rate',
            color: AppColors.warningAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard({
    required String name,
    required String email,
    required String role,
    required List<String> sites,
    required String status,
    required String lastSeen,
    required bool isActive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => _navigateToEmployeeDetail(name, email),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isActive ? AppColors.accentGreen : AppColors.gray400,
                    child: Text(
                      name.split(' ').map((n) => n[0]).join(''),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.bodyLarge),
                        Text(email,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray600)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accentGreen.withOpacity(0.1)
                          : AppColors.gray400.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isActive
                            ? AppColors.accentGreen
                            : AppColors.gray600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  const Icon(Icons.work_outline,
                      size: 16, color: AppColors.gray600),
                  const SizedBox(width: 4),
                  Text(role,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                  const SizedBox(width: AppConstants.defaultPadding),
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.gray600),
                  const SizedBox(width: 4),
                  Text(sites.join(', '),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Last seen: $lastSeen',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray500)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editEmployee(name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () => _showEmployeeOptions(name),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics, color: color),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                Text(value, style: AppTextStyles.heading3),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    // TODO: Implement search functionality
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
  }

  void _showAddEmployeeDialog() {
    // TODO: Navigate to add employee page
  }

  void _showBulkImportDialog() {
    // TODO: Implement bulk import dialog
  }

  void _exportEmployeeData() {
    // TODO: Implement export functionality
  }

  void _editEmployee(String name) {
    // TODO: Navigate to edit employee page
  }

  void _showEmployeeOptions(String name) {
    // TODO: Show employee options menu
  }

  // Navigation method for employee detail
  void _navigateToEmployeeDetail(String name, String email) {
    // Generate a mock employee ID based on email
    final employeeId = email.split('@')[0];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(
          employeeId: employeeId,
          employeeName: name,
        ),
      ),
    );
  }
}
