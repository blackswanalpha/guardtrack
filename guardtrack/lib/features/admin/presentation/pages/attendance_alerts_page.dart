import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

class AttendanceAlertsPage extends StatefulWidget {
  const AttendanceAlertsPage({super.key});

  @override
  State<AttendanceAlertsPage> createState() => _AttendanceAlertsPageState();
}

class _AttendanceAlertsPageState extends State<AttendanceAlertsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock alert data
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'type': 'late_arrival',
      'employee': 'John Smith',
      'site': 'Site Alpha',
      'message': 'Late arrival - 15 minutes',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'severity': 'medium',
      'status': 'active',
    },
    {
      'id': '2',
      'type': 'no_show',
      'employee': 'Sarah Johnson',
      'site': 'Site Beta',
      'message': 'No show for scheduled shift',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'severity': 'high',
      'status': 'active',
    },
    {
      'id': '3',
      'type': 'early_departure',
      'employee': 'Mike Wilson',
      'site': 'Site Gamma',
      'message': 'Left 30 minutes early',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'severity': 'low',
      'status': 'resolved',
    },
    {
      'id': '4',
      'type': 'location_mismatch',
      'employee': 'Emma Davis',
      'site': 'Site Delta',
      'message': 'Check-in outside geofence boundary',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'severity': 'medium',
      'status': 'investigating',
    },
  ];

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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveAlerts(),
                _buildResolvedAlerts(),
                _buildAlertSettings(),
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
        'Attendance Alerts',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_off, color: AppColors.white),
          onPressed: _muteAllAlerts,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: _refreshAlerts,
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final activeAlerts = _alerts.where((a) => a['status'] == 'active').length;
    final highPriorityAlerts = _alerts.where((a) => a['severity'] == 'high' && a['status'] == 'active').length;
    final resolvedToday = _alerts.where((a) => a['status'] == 'resolved').length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Alerts',
              activeAlerts.toString(),
              AppColors.warningAmber,
              Icons.warning,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              'High Priority',
              highPriorityAlerts.toString(),
              AppColors.errorRed,
              Icons.priority_high,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              'Resolved Today',
              resolvedToday.toString(),
              AppColors.accentGreen,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: color),
            textAlign: TextAlign.center,
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
          Tab(text: 'Active'),
          Tab(text: 'Resolved'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts() {
    final activeAlerts = _alerts.where((a) => a['status'] == 'active').toList();
    
    if (activeAlerts.isEmpty) {
      return _buildEmptyState('No active alerts', 'All attendance is on track!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: activeAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(activeAlerts[index]);
      },
    );
  }

  Widget _buildResolvedAlerts() {
    final resolvedAlerts = _alerts.where((a) => a['status'] == 'resolved').toList();
    
    if (resolvedAlerts.isEmpty) {
      return _buildEmptyState('No resolved alerts', 'Resolved alerts will appear here');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: resolvedAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(resolvedAlerts[index], isResolved: true);
      },
    );
  }

  Widget _buildAlertSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alert Configuration', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Late Arrival Threshold',
            'Alert when employee is late by:',
            '15 minutes',
            Icons.access_time,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'No Show Alert',
            'Alert when no check-in after:',
            '30 minutes',
            Icons.person_off,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Geofence Tolerance',
            'Alert when check-in is outside:',
            '50 meters',
            Icons.location_off,
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text('Notification Settings', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildNotificationSettings(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, {bool isResolved = false}) {
    final severityColor = _getSeverityColor(alert['severity']);
    final alertIcon = _getAlertIcon(alert['type']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(alertIcon, color: severityColor, size: 20),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['employee'],
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        alert['site'],
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert['severity'].toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: severityColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              alert['message'],
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(alert['timestamp']),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
                ),
                if (!isResolved)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _resolveAlert(alert['id']),
                        child: const Text('Resolve'),
                      ),
                      TextButton(
                        onPressed: () => _viewAlertDetails(alert),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, String subtitle, String value, IconData icon) {
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
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: AppConstants.smallPadding),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
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
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts on mobile device'),
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive alerts via email'),
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive critical alerts via SMS'),
            value: false,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppColors.errorRed;
      case 'medium':
        return AppColors.warningAmber;
      case 'low':
        return AppColors.primaryBlue;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'late_arrival':
        return Icons.access_time;
      case 'no_show':
        return Icons.person_off;
      case 'early_departure':
        return Icons.exit_to_app;
      case 'location_mismatch':
        return Icons.location_off;
      default:
        return Icons.warning;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _muteAllAlerts() {
    // TODO: Implement mute functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All alerts muted for 1 hour')),
    );
  }

  void _refreshAlerts() {
    // TODO: Implement refresh functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerts refreshed')),
    );
  }

  void _resolveAlert(String alertId) {
    setState(() {
      final alertIndex = _alerts.indexWhere((a) => a['id'] == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex]['status'] = 'resolved';
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert resolved'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _viewAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alert Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee: ${alert['employee']}'),
            Text('Site: ${alert['site']}'),
            Text('Type: ${alert['type']}'),
            Text('Severity: ${alert['severity']}'),
            Text('Time: ${_formatTimestamp(alert['timestamp'])}'),
            const SizedBox(height: AppConstants.defaultPadding),
            Text('Message:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(alert['message']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          CustomButton(
            text: 'Resolve',
            onPressed: () {
              Navigator.pop(context);
              _resolveAlert(alert['id']);
            },
            type: ButtonType.text,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
