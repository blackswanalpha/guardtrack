import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class NotificationsManagementPage extends StatefulWidget {
  const NotificationsManagementPage({super.key});

  @override
  State<NotificationsManagementPage> createState() =>
      _NotificationsManagementPageState();
}

class _NotificationsManagementPageState
    extends State<NotificationsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Monthly Safety Reminder',
      'message': 'Please review the updated safety protocols',
      'type': 'announcement',
      'recipients': 'All Guards',
      'status': 'sent',
      'sentDate': DateTime.now().subtract(const Duration(hours: 2)),
      'deliveryRate': 0.95,
      'readRate': 0.78,
    },
    {
      'id': '2',
      'title': 'Shift Change Alert',
      'message': 'Your shift starts in 30 minutes',
      'type': 'alert',
      'recipients': 'Night Shift Guards',
      'status': 'scheduled',
      'sentDate': DateTime.now().add(const Duration(minutes: 30)),
      'deliveryRate': 0.0,
      'readRate': 0.0,
    },
    {
      'id': '3',
      'title': 'Emergency Protocol Update',
      'message': 'New emergency procedures have been implemented',
      'type': 'urgent',
      'recipients': 'All Staff',
      'status': 'sent',
      'sentDate': DateTime.now().subtract(const Duration(days: 1)),
      'deliveryRate': 0.98,
      'readRate': 0.89,
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
                _buildNotificationsList(),
                _buildTemplatesTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "notifications_management_fab",
        onPressed: _createNotification,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: Text(
        'Notifications',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: AppColors.white),
          onPressed: _viewHistory,
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final sentCount = _notifications.where((n) => n['status'] == 'sent').length;
    final scheduledCount =
        _notifications.where((n) => n['status'] == 'scheduled').length;
    final avgDeliveryRate = _notifications
            .where((n) => n['status'] == 'sent')
            .map((n) => n['deliveryRate'] as double)
            .fold(0.0, (a, b) => a + b) /
        sentCount;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Sent Today',
              sentCount.toString(),
              AppColors.accentGreen,
              Icons.send,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              'Scheduled',
              scheduledCount.toString(),
              AppColors.warningAmber,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              'Delivery Rate',
              '${(avgDeliveryRate * 100).toInt()}%',
              AppColors.primaryBlue,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
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
          Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: color)),
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
          Tab(text: 'All Notifications'),
          Tab(text: 'Templates'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(_notifications[index]);
      },
    );
  }

  Widget _buildTemplatesTab() {
    final templates = [
      {
        'name': 'Shift Reminder',
        'description': 'Standard shift change notification'
      },
      {'name': 'Safety Alert', 'description': 'Emergency safety notification'},
      {'name': 'Policy Update', 'description': 'Company policy changes'},
      {
        'name': 'Training Notice',
        'description': 'Training session announcements'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Message Templates', style: AppTextStyles.heading4),
              CustomButton(
                text: 'Create Template',
                onPressed: _createTemplate,
                type: ButtonType.outline,
                isFullWidth: false,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ...templates
              .map((template) => Card(
                    margin: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding),
                    child: ListTile(
                      leading: const Icon(Icons.message,
                          color: AppColors.primaryBlue),
                      title: Text(template['name']!),
                      subtitle: Text(template['description']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editTemplate(template['name']!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, size: 20),
                            onPressed: () => _useTemplate(template['name']!),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Settings', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Push Notifications',
            'Configure mobile push notifications',
            Icons.notifications,
            true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'Email Notifications',
            'Configure email delivery settings',
            Icons.email,
            true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSettingsCard(
            'SMS Notifications',
            'Configure SMS delivery settings',
            Icons.sms,
            false,
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text('Delivery Settings', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildDeliverySettings(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final typeColor = _getTypeColor(notification['type']);
    final statusColor = _getStatusColor(notification['status']);

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
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(notification['type']),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        notification['recipients'],
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notification['status'].toString().toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              notification['message'],
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (notification['status'] == 'sent') ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Delivered',
                      '${(notification['deliveryRate'] * 100).toInt()}%',
                      AppColors.accentGreen,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Read',
                      '${(notification['readRate'] * 100).toInt()}%',
                      AppColors.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Sent',
                      _formatDate(notification['sentDate']),
                      AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled: ${_formatDate(notification['sentDate'])}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray500),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _editNotification(notification['id']),
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () =>
                            _cancelNotification(notification['id']),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
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
    );
  }

  Widget _buildSettingsCard(
      String title, String subtitle, IconData icon, bool isEnabled) {
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
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // TODO: Update setting
            },
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySettings() {
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
          Text('Delivery Options', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppConstants.defaultPadding),
          CheckboxListTile(
            title: const Text('Retry failed deliveries'),
            subtitle: const Text('Automatically retry failed notifications'),
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
          CheckboxListTile(
            title: const Text('Delivery confirmations'),
            subtitle: const Text('Request read receipts when possible'),
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
          CheckboxListTile(
            title: const Text('Quiet hours'),
            subtitle: const Text('Respect user quiet hours (10 PM - 6 AM)'),
            value: false,
            onChanged: (value) {},
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return AppColors.errorRed;
      case 'alert':
        return AppColors.warningAmber;
      case 'announcement':
        return AppColors.primaryBlue;
      default:
        return AppColors.gray500;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sent':
        return AppColors.accentGreen;
      case 'scheduled':
        return AppColors.warningAmber;
      case 'failed':
        return AppColors.errorRed;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.priority_high;
      case 'alert':
        return Icons.warning;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.message;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m';
    } else if (difference.inHours < 0) {
      return '${difference.inHours.abs()}h ago';
    } else {
      return '${difference.inMinutes.abs()}m ago';
    }
  }

  void _createNotification() {
    _showNotificationDialog();
  }

  void _showNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'announcement';
    String selectedRecipients = 'All Guards';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Title',
                hint: 'Enter notification title',
                controller: titleController,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                label: 'Message',
                hint: 'Enter notification message',
                controller: messageController,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['announcement', 'alert', 'urgent'].map((type) {
                  return DropdownMenuItem(
                      value: type, child: Text(type.toUpperCase()));
                }).toList(),
                onChanged: (value) => selectedType = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Send Now',
            onPressed: () {
              Navigator.pop(context);
              _sendNotification(
                  titleController.text, messageController.text, selectedType);
            },
            type: ButtonType.text,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _sendNotification(String title, String message, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification sent successfully'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _viewHistory() {
    // Navigate to notification history
  }

  void _createTemplate() {
    // Navigate to create template page
  }

  void _editTemplate(String templateName) {
    // Navigate to edit template page
  }

  void _useTemplate(String templateName) {
    // Use template to create notification
  }

  void _editNotification(String notificationId) {
    // Edit scheduled notification
  }

  void _cancelNotification(String notificationId) {
    // Cancel scheduled notification
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification cancelled'),
        backgroundColor: AppColors.warningAmber,
      ),
    );
  }
}
