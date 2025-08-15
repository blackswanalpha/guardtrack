import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class SupportHelpPage extends StatefulWidget {
  const SupportHelpPage({super.key});

  @override
  State<SupportHelpPage> createState() => _SupportHelpPageState();
}

class _SupportHelpPageState extends State<SupportHelpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I reset a user\'s password?',
      'answer': 'Go to Employee Management, select the user, and click "Reset Password" from the menu.',
      'category': 'User Management',
    },
    {
      'question': 'How do I configure geofencing for a site?',
      'answer': 'Navigate to Site Management, select the site, go to Settings tab, and adjust the geofence radius.',
      'category': 'Site Management',
    },
    {
      'question': 'How can I export attendance reports?',
      'answer': 'Go to Reports section, select the desired report type, choose date range, and click Export.',
      'category': 'Reports',
    },
    {
      'question': 'How do I send notifications to specific groups?',
      'answer': 'In Notifications, create a new notification and select the target group from the recipients dropdown.',
      'category': 'Notifications',
    },
    {
      'question': 'What should I do if location tracking is not working?',
      'answer': 'Check GPS permissions, ensure location services are enabled, and verify geofence settings.',
      'category': 'Technical Issues',
    },
  ];

  final List<Map<String, dynamic>> _supportTickets = [
    {
      'id': 'TICK-001',
      'title': 'GPS accuracy issues',
      'description': 'Some guards are experiencing GPS accuracy problems',
      'status': 'open',
      'priority': 'high',
      'created': DateTime.now().subtract(const Duration(hours: 2)),
      'category': 'Technical',
    },
    {
      'id': 'TICK-002',
      'title': 'Report export not working',
      'description': 'Unable to export monthly attendance reports',
      'status': 'in_progress',
      'priority': 'medium',
      'created': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Feature Request',
    },
    {
      'id': 'TICK-003',
      'title': 'New site setup assistance',
      'description': 'Need help setting up geofencing for new location',
      'status': 'resolved',
      'priority': 'low',
      'created': DateTime.now().subtract(const Duration(days: 3)),
      'category': 'Support',
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
          _buildQuickActions(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHelpCenterTab(),
                _buildSupportTicketsTab(),
                _buildContactSupportTab(),
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
        'Support & Help',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: _searchHelp,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              'User Guide',
              Icons.book,
              AppColors.primaryBlue,
              () => _openUserGuide(),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildQuickActionCard(
              'Video Tutorials',
              Icons.play_circle,
              AppColors.accentGreen,
              () => _openVideoTutorials(),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildQuickActionCard(
              'Live Chat',
              Icons.chat,
              AppColors.warningAmber,
              () => _startLiveChat(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
          Tab(text: 'Help Center'),
          Tab(text: 'Support Tickets'),
          Tab(text: 'Contact Support'),
        ],
      ),
    );
  }

  Widget _buildHelpCenterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently Asked Questions', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          ..._faqItems.map((faq) => _buildFaqItem(faq)).toList(),
          const SizedBox(height: AppConstants.largePadding),
          Text('Quick Links', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildQuickLinksList(),
        ],
      ),
    );
  }

  Widget _buildSupportTicketsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Support Tickets', style: AppTextStyles.heading4),
              CustomButton(
                text: 'New Ticket',
                onPressed: _createSupportTicket,
                type: ButtonType.outline,
                isFullWidth: false,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildTicketStats(),
          const SizedBox(height: AppConstants.defaultPadding),
          ..._supportTickets.map((ticket) => _buildTicketCard(ticket)).toList(),
        ],
      ),
    );
  }

  Widget _buildContactSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildContactCard(),
          const SizedBox(height: AppConstants.largePadding),
          Text('Send us a Message', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ExpansionTile(
        title: Text(faq['question']),
        subtitle: Text(
          faq['category'],
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              faq['answer'],
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksList() {
    final quickLinks = [
      {'title': 'Getting Started Guide', 'icon': Icons.play_arrow},
      {'title': 'Admin Dashboard Overview', 'icon': Icons.dashboard},
      {'title': 'Employee Management Guide', 'icon': Icons.people},
      {'title': 'Site Configuration Help', 'icon': Icons.location_on},
      {'title': 'Reports and Analytics', 'icon': Icons.analytics},
      {'title': 'Troubleshooting Guide', 'icon': Icons.build},
    ];

    return Column(
      children: quickLinks.map((link) => Card(
        margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
        child: ListTile(
          leading: Icon(link['icon'] as IconData, color: AppColors.primaryBlue),
          title: Text(link['title'] as String),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openHelpArticle(link['title'] as String),
        ),
      )).toList(),
    );
  }

  Widget _buildTicketStats() {
    final openTickets = _supportTickets.where((t) => t['status'] == 'open').length;
    final inProgressTickets = _supportTickets.where((t) => t['status'] == 'in_progress').length;
    final resolvedTickets = _supportTickets.where((t) => t['status'] == 'resolved').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatChip('Open', openTickets.toString(), AppColors.errorRed),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatChip('In Progress', inProgressTickets.toString(), AppColors.warningAmber),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatChip('Resolved', resolvedTickets.toString(), AppColors.accentGreen),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final statusColor = _getStatusColor(ticket['status']);
    final priorityColor = _getPriorityColor(ticket['priority']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket['title'],
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket['priority'].toString().toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: priorityColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'ID: ${ticket['id']} • ${ticket['category']}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(ticket['description']),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket['status'].toString().replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                  ),
                ),
                Text(
                  _formatDate(ticket['created']),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
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
          _buildContactRow(Icons.email, 'Email', 'support@guardtrack.com'),
          const Divider(),
          _buildContactRow(Icons.phone, 'Phone', '+1 (555) 123-4567'),
          const Divider(),
          _buildContactRow(Icons.access_time, 'Hours', 'Mon-Fri 9AM-6PM EST'),
          const Divider(),
          _buildContactRow(Icons.language, 'Website', 'www.guardtrack.com/support'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: AppConstants.defaultPadding),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

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
          CustomTextField(
            label: 'Subject',
            hint: 'Enter message subject',
            controller: subjectController,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Message',
            hint: 'Describe your issue or question',
            controller: messageController,
            maxLines: 5,
          ),
          const SizedBox(height: AppConstants.largePadding),
          CustomButton(
            text: 'Send Message',
            onPressed: () => _sendMessage(subjectController.text, messageController.text),
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.errorRed;
      case 'in_progress':
        return AppColors.warningAmber;
      case 'resolved':
        return AppColors.accentGreen;
      default:
        return AppColors.gray500;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  void _searchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Help'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Search',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.text,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _openUserGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening user guide...')),
    );
  }

  void _openVideoTutorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening video tutorials...')),
    );
  }

  void _startLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting live chat...')),
    );
  }

  void _openHelpArticle(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $title')),
    );
  }

  void _createSupportTicket() {
    // Navigate to create support ticket page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening ticket creation form...')),
    );
  }

  void _sendMessage(String subject, String message) {
    if (subject.isNotEmpty && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully! We\'ll respond within 24 hours.'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
