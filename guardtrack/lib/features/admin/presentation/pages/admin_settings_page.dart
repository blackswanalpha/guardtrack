import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSystemSettingsTab(),
                _buildUserRolesTab(),
                _buildGeofencingTab(),
                _buildIntegrationsTab(),
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
        'Admin Settings',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.backup, color: AppColors.white),
          onPressed: _backupSettings,
        ),
      ],
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
        isScrollable: true,
        tabs: const [
          Tab(text: 'System'),
          Tab(text: 'User Roles'),
          Tab(text: 'Geofencing'),
          Tab(text: 'Integrations'),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Company Settings', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Company Profile',
            'Update company information and branding',
            Icons.business,
            () => _editCompanyProfile(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'App Configuration',
            'Configure app behavior and features',
            Icons.settings,
            () => _configureApp(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Security Settings',
            'Password policies and security options',
            Icons.security,
            () => _configureSecuritySettings(),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text('Data Management', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Data Backup',
            'Backup and restore system data',
            Icons.backup,
            () => _manageBackups(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Data Export',
            'Export data for reporting or migration',
            Icons.download,
            () => _exportData(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Data Retention',
            'Configure data retention policies',
            Icons.schedule,
            () => _configureRetention(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Roles & Permissions', style: AppTextStyles.heading4),
              CustomButton(
                text: 'Create Role',
                onPressed: _createRole,
                type: ButtonType.outline,
                isFullWidth: false,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildRoleCard(
            'Super Admin',
            'Full system access and control',
            ['All permissions'],
            AppColors.errorRed,
            2,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildRoleCard(
            'Admin',
            'Administrative access with some restrictions',
            ['Employee Management', 'Site Management', 'Reports', 'Notifications'],
            AppColors.primaryBlue,
            5,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildRoleCard(
            'Supervisor',
            'Limited administrative access',
            ['View Reports', 'Manage Assignments', 'View Attendance'],
            AppColors.warningAmber,
            12,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildRoleCard(
            'Guard',
            'Basic user access',
            ['Check In/Out', 'View Assignments', 'Update Profile'],
            AppColors.accentGreen,
            156,
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Geofencing Configuration', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildGeofenceSettingCard(
            'Default Radius',
            'Default geofence radius for new sites',
            '100 meters',
            Icons.radio_button_unchecked,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildGeofenceSettingCard(
            'Location Accuracy',
            'Required GPS accuracy for check-ins',
            '10 meters',
            Icons.gps_fixed,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildGeofenceSettingCard(
            'Check-in Tolerance',
            'Time window for location verification',
            '30 seconds',
            Icons.timer,
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text('Location Services', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildToggleSettingCard(
            'Background Location',
            'Allow location tracking in background',
            true,
            Icons.location_on,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildToggleSettingCard(
            'Location History',
            'Store location history for analysis',
            true,
            Icons.history,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildToggleSettingCard(
            'Offline Mode',
            'Allow check-ins when offline',
            false,
            Icons.cloud_off,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('External Integrations', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildIntegrationCard(
            'Google Maps',
            'Maps and location services',
            true,
            Icons.map,
            'Connected',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildIntegrationCard(
            'Email Service',
            'Email notifications and reports',
            true,
            Icons.email,
            'SMTP Configured',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildIntegrationCard(
            'SMS Gateway',
            'SMS notifications and alerts',
            false,
            Icons.sms,
            'Not Configured',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildIntegrationCard(
            'Push Notifications',
            'Mobile push notification service',
            true,
            Icons.notifications,
            'Firebase Connected',
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text('API Configuration', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildApiConfigCard(),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRoleCard(String role, String description, List<String> permissions, Color color, int userCount) {
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
                child: Icon(Icons.admin_panel_settings, color: color),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              Text('$userCount users', style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text('Permissions:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: permissions.map((permission) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                permission,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _editRole(role),
                child: const Text('Edit'),
              ),
              if (role != 'Super Admin')
                TextButton(
                  onPressed: () => _deleteRole(role),
                  child: Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceSettingCard(String title, String description, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 16),
          ],
        ),
        onTap: () => _editGeofenceSetting(title),
      ),
    );
  }

  Widget _buildToggleSettingCard(String title, String description, bool value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title),
        subtitle: Text(description),
        trailing: Switch(
          value: value,
          onChanged: (newValue) => _toggleSetting(title, newValue),
          activeColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildIntegrationCard(String name, String description, bool isConnected, IconData icon, String status) {
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
              color: isConnected ? AppColors.accentGreen.withOpacity(0.1) : AppColors.gray400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isConnected ? AppColors.accentGreen : AppColors.gray400),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyLarge),
                Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isConnected ? AppColors.accentGreen.withOpacity(0.1) : AppColors.gray400.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isConnected ? AppColors.accentGreen : AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            text: isConnected ? 'Configure' : 'Setup',
            onPressed: () => _configureIntegration(name),
            type: ButtonType.outline,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildApiConfigCard() {
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
          Text('API Settings', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildApiRow('Base URL', 'https://api.guardtrack.com'),
          _buildApiRow('API Version', 'v1.2.0'),
          _buildApiRow('Rate Limit', '1000 requests/hour'),
          _buildApiRow('Timeout', '30 seconds'),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Generate API Key',
                  onPressed: _generateApiKey,
                  type: ButtonType.outline,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Test Connection',
                  onPressed: _testApiConnection,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _backupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings backup created successfully')),
    );
  }

  void _editCompanyProfile() {
    // Navigate to company profile edit
  }

  void _configureApp() {
    // Navigate to app configuration
  }

  void _configureSecuritySettings() {
    // Navigate to security settings
  }

  void _manageBackups() {
    // Navigate to backup management
  }

  void _exportData() {
    // Navigate to data export
  }

  void _configureRetention() {
    // Navigate to retention policy
  }

  void _createRole() {
    // Navigate to create role page
  }

  void _editRole(String role) {
    // Navigate to edit role page
  }

  void _deleteRole(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete the $role role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Delete',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$role role deleted')),
              );
            },
            type: ButtonType.text,
            textColor: AppColors.errorRed,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _editGeofenceSetting(String setting) {
    // Show edit dialog for geofence setting
  }

  void _toggleSetting(String setting, bool value) {
    // Update setting value
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$setting ${value ? 'enabled' : 'disabled'}')),
    );
  }

  void _configureIntegration(String integration) {
    // Navigate to integration configuration
  }

  void _generateApiKey() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New API key generated')),
    );
  }

  void _testApiConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API connection test successful'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }
}
