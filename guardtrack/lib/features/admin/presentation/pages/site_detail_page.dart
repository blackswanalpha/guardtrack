import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/models/user_model.dart';

class SiteDetailPage extends StatefulWidget {
  final String siteId;
  final String siteName;

  const SiteDetailPage({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<SiteDetailPage> createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Enhanced site data
  late SiteModel _siteData;
  late List<UserModel> _assignedPersonnel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSiteData();
    _loadPersonnelData();
  }

  void _loadSiteData() {
    // Mock enhanced site data
    _siteData = SiteModel(
      id: widget.siteId,
      name: widget.siteName,
      address: '123 Business District, City Center, Nairobi',
      latitude: -1.2921,
      longitude: 36.8219,
      allowedRadius: 100.0,
      isActive: true,
      description:
          'Premium office complex with 24/7 security coverage and advanced surveillance systems',
      contactPerson: 'John Manager',
      contactPhone: '+254700123456',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      assignedGuardIds: ['guard1', 'guard2', 'guard3', 'guard4'],
      emergencyContact: '+254700999888',
      shiftStartTime: '06:00',
      shiftEndTime: '22:00',
      specialInstructions:
          'High-security zone. All visitors must be escorted. Regular patrol every 2 hours.',
    );
  }

  void _loadPersonnelData() {
    // Mock assigned personnel data
    _assignedPersonnel = [
      UserModel(
        id: 'guard1',
        email: 'john.smith@company.com',
        firstName: 'John',
        lastName: 'Smith',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        phone: '+254700111222',
        assignedSiteIds: [widget.siteId],
      ),
      UserModel(
        id: 'guard2',
        email: 'sarah.johnson@company.com',
        firstName: 'Sarah',
        lastName: 'Johnson',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        phone: '+254700333444',
        assignedSiteIds: [widget.siteId],
      ),
      UserModel(
        id: 'guard3',
        email: 'mike.wilson@company.com',
        firstName: 'Mike',
        lastName: 'Wilson',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        phone: '+254700555666',
        assignedSiteIds: [widget.siteId],
      ),
      UserModel(
        id: 'guard4',
        email: 'emma.davis@company.com',
        firstName: 'Emma',
        lastName: 'Davis',
        role: UserRole.guard,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        phone: '+254700777888',
        assignedSiteIds: [widget.siteId],
      ),
    ];
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSiteHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSiteInformationTab(),
                _buildAssignedPersonnelTab(),
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
        'Site Details',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.white),
          onPressed: _editSite,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'deactivate', child: Text('Deactivate Site')),
            const PopupMenuItem(value: 'export', child: Text('Export Data')),
            const PopupMenuItem(
                value: 'duplicate', child: Text('Duplicate Site')),
          ],
        ),
      ],
    );
  }

  Widget _buildSiteHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _siteData.name,
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      'ID: ${_siteData.id}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _siteData.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: _siteData.isActive
                          ? AppColors.accentGreen
                          : AppColors.errorRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            _siteData.address,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            Icons.people,
            '${_assignedPersonnel.length}',
            'Guards',
            AppColors.primaryBlue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            Icons.access_time,
            '${_siteData.shiftStartTime} - ${_siteData.shiftEndTime}',
            'Coverage',
            AppColors.accentGreen,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            Icons.location_searching,
            '${_siteData.allowedRadius.toInt()}m',
            'Geofence',
            AppColors.warningAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
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
          Tab(text: 'Site Information'),
          Tab(text: 'Assigned Personnel'),
        ],
      ),
    );
  }

  Widget _buildSiteInformationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Site Information',
            [
              _buildInfoRow('Site Name', _siteData.name),
              _buildInfoRow('Site ID', _siteData.id),
              _buildInfoRow('Address', _siteData.address),
              _buildInfoRow(
                  'Status', _siteData.isActive ? 'ACTIVE' : 'INACTIVE'),
              _buildInfoRow('Created', _formatDate(_siteData.createdAt)),
              _buildInfoRow('Site Type', 'Commercial Office Complex'),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildInfoCard(
            'Contact Information',
            [
              _buildInfoRow(
                  'Site Manager', _siteData.contactPerson ?? 'Not assigned'),
              _buildInfoRow(
                  'Manager Phone', _siteData.contactPhone ?? 'Not provided'),
              _buildInfoRow('Emergency Contact',
                  _siteData.emergencyContact ?? 'Not provided'),
              _buildInfoRow('Site Email',
                  'site.${_siteData.id.toLowerCase()}@company.com'),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildInfoCard(
            'Security Configuration',
            [
              _buildInfoRow('Geofence Radius',
                  '${_siteData.allowedRadius.toInt()} meters'),
              _buildInfoRow('Shift Hours',
                  '${_siteData.shiftStartTime} - ${_siteData.shiftEndTime}'),
              _buildInfoRow(
                  'Assigned Guards', '${_assignedPersonnel.length} guards'),
              _buildInfoRow('Latitude', _siteData.latitude.toStringAsFixed(6)),
              _buildInfoRow(
                  'Longitude', _siteData.longitude.toStringAsFixed(6)),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildEnhancedMapSection(),
        ],
      ),
    );
  }

  Widget _buildAssignedPersonnelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assigned Personnel (${_assignedPersonnel.length})',
                  style: AppTextStyles.heading4),
              CustomButton(
                text: 'Assign Guard',
                onPressed: _assignGuard,
                type: ButtonType.outline,
                isFullWidth: false,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildEnhancedPersonnelList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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

  Widget _buildEnhancedMapSection() {
    return Container(
      height: 300,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Site Location & Geofence', style: AppTextStyles.heading4),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _openInMaps(),
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Open in Maps',
                  ),
                  IconButton(
                    onPressed: () => _shareLocation(),
                    icon: const Icon(Icons.share, size: 20),
                    tooltip: 'Share Location',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 64, color: AppColors.gray400),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Interactive Site Map',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.gray600),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Lat: ${_siteData.latitude.toStringAsFixed(6)}, Lng: ${_siteData.longitude.toStringAsFixed(6)}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray500),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Geofence: ${_siteData.allowedRadius.toInt()}m radius',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPersonnelList() {
    return Column(
      children: [
        // Personnel Statistics
        Container(
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
              Expanded(
                child: Column(
                  children: [
                    Text(
                        '${_assignedPersonnel.where((p) => p.isActive).length}',
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
                    Text(
                        '${_assignedPersonnel.where((p) => !p.isActive).length}',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.errorRed)),
                    Text('Inactive',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${_assignedPersonnel.length}',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.primaryBlue)),
                    Text('Total',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Personnel List
        ..._assignedPersonnel.map((person) => _buildPersonnelCard(person)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPersonnelCard(UserModel person) {
    final isActive = person.isActive;
    final assignedDate = person.createdAt;
    final daysSinceAssigned = DateTime.now().difference(assignedDate).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.accentGreen : AppColors.gray400,
          child: Text(
            '${person.firstName[0]}${person.lastName[0]}',
            style: const TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(person.fullName, style: AppTextStyles.heading4),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(person.email,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accentGreen.withOpacity(0.1)
                        : AppColors.gray400.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isActive ? AppColors.accentGreen : AppColors.gray600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    person.role.name.toUpperCase(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryBlue),
                  ),
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
                _buildInfoRow('Employee ID', person.id),
                _buildInfoRow('Phone', person.phone ?? 'Not provided'),
                _buildInfoRow('Role', person.role.name.toUpperCase()),
                _buildInfoRow('Assignment Date', _formatDate(assignedDate)),
                _buildInfoRow('Days Assigned', '$daysSinceAssigned days'),
                _buildInfoRow('Shift Schedule',
                    '${_siteData.shiftStartTime} - ${_siteData.shiftEndTime}'),
                const SizedBox(height: AppConstants.defaultPadding),
                Text('Performance Summary', style: AppTextStyles.heading4),
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.all(AppConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text('94.2%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.accentGreen,
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
                        padding:
                            const EdgeInsets.all(AppConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text('4.8/5',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text('Rating',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.gray600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.all(AppConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: AppColors.warningAmber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text('2',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.warningAmber,
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
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewEmployeeDetails(person),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactEmployee(person),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
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
  }

  void _openInMaps() {
    // TODO: Implement opening location in maps app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening in Maps...')),
    );
  }

  void _shareLocation() {
    // TODO: Implement sharing location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location shared')),
    );
  }

  void _viewEmployeeDetails(UserModel employee) {
    Navigator.pushNamed(context, '/admin/employee/detail', arguments: {
      'employeeId': employee.id,
      'employeeName': employee.fullName,
    });
  }

  void _contactEmployee(UserModel employee) {
    // TODO: Implement contact functionality (call, SMS, email)
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contact ${employee.fullName}', style: AppTextStyles.heading3),
            const SizedBox(height: AppConstants.defaultPadding),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: Text(employee.phone ?? 'No phone number'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('SMS'),
              subtitle: Text(employee.phone ?? 'No phone number'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(employee.email),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editSite() {
    Navigator.pushNamed(context, '/admin/site/edit', arguments: _siteData);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'deactivate':
        _showDeactivateDialog();
        break;
      case 'export':
        _exportSiteData();
        break;
      case 'duplicate':
        _duplicateSite();
        break;
    }
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Site'),
        content: Text('Are you sure you want to deactivate ${_siteData.name}?'),
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
            textColor: AppColors.errorRed,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _exportSiteData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Site data exported successfully')),
    );
  }

  void _duplicateSite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Site duplicated successfully')),
    );
  }

  void _assignGuard() {
    // Navigate to assign guard page
  }
}
