import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

class AssignmentManagementPage extends StatefulWidget {
  const AssignmentManagementPage({super.key});

  @override
  State<AssignmentManagementPage> createState() =>
      _AssignmentManagementPageState();
}

class _AssignmentManagementPageState extends State<AssignmentManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Active', 'Completed', 'Overdue'];

  // Mock assignment data
  final List<Map<String, dynamic>> _assignments = [
    {
      'id': '1',
      'title': 'Night Security Patrol',
      'description': 'Complete security rounds every 2 hours',
      'assignedTo': ['John Smith', 'Sarah Johnson'],
      'site': 'Site Alpha',
      'priority': 'high',
      'status': 'active',
      'dueDate': DateTime.now().add(const Duration(hours: 8)),
      'createdDate': DateTime.now().subtract(const Duration(days: 1)),
      'progress': 0.6,
    },
    {
      'id': '2',
      'title': 'Access Control Check',
      'description': 'Verify all entry points are secure',
      'assignedTo': ['Mike Wilson'],
      'site': 'Site Beta',
      'priority': 'medium',
      'status': 'completed',
      'dueDate': DateTime.now().subtract(const Duration(hours: 2)),
      'createdDate': DateTime.now().subtract(const Duration(days: 2)),
      'progress': 1.0,
    },
    {
      'id': '3',
      'title': 'Equipment Maintenance',
      'description': 'Check and maintain security equipment',
      'assignedTo': ['Emma Davis', 'Tom Brown'],
      'site': 'Site Gamma',
      'priority': 'low',
      'status': 'overdue',
      'dueDate': DateTime.now().subtract(const Duration(hours: 12)),
      'createdDate': DateTime.now().subtract(const Duration(days: 3)),
      'progress': 0.3,
    },
    {
      'id': '4',
      'title': 'Incident Report Review',
      'description': 'Review and process incident reports',
      'assignedTo': ['Lisa Anderson'],
      'site': 'Site Delta',
      'priority': 'high',
      'status': 'active',
      'dueDate': DateTime.now().add(const Duration(hours: 4)),
      'createdDate': DateTime.now().subtract(const Duration(hours: 6)),
      'progress': 0.8,
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
          _buildFilterBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssignmentsList(),
                _buildCalendarView(),
                _buildAnalyticsView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "assignment_management_fab",
        onPressed: _createNewAssignment,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: Text(
        'Assignment Management',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: AppColors.white),
          onPressed: _showAdvancedFilters,
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final activeCount =
        _assignments.where((a) => a['status'] == 'active').length;
    final completedCount =
        _assignments.where((a) => a['status'] == 'completed').length;
    final overdueCount =
        _assignments.where((a) => a['status'] == 'overdue').length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active', activeCount.toString(),
                AppColors.primaryBlue, Icons.assignment),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard('Completed', completedCount.toString(),
                AppColors.accentGreen, Icons.check_circle),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard('Overdue', overdueCount.toString(),
                AppColors.errorRed, Icons.warning),
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding),
      color: AppColors.white,
      child: Row(
        children: [
          Text('Filter: ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: AppConstants.smallPadding),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryBlue,
                    ),
                  );
                }).toList(),
              ),
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
          Tab(text: 'List View'),
          Tab(text: 'Calendar'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    final filteredAssignments = _getFilteredAssignments();

    if (filteredAssignments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: filteredAssignments.length,
      itemBuilder: (context, index) {
        return _buildAssignmentCard(filteredAssignments[index]);
      },
    );
  }

  Widget _buildCalendarView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 64, color: AppColors.gray400),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Calendar View',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Assignment calendar integration pending',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assignment Analytics', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard(
              'Completion Rate', '78%', 'This month', AppColors.accentGreen),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard('Average Time', '4.2 hours', 'Per assignment',
              AppColors.primaryBlue),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAnalyticsCard(
              'Overdue Rate', '12%', 'This month', AppColors.errorRed),
          const SizedBox(height: AppConstants.largePadding),
          Text('Top Performers', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildPerformersList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.gray400),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No assignments found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Create your first assignment to get started',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: AppConstants.largePadding),
          CustomButton(
            text: 'Create Assignment',
            onPressed: _createNewAssignment,
            icon: Icons.add,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final statusColor = _getStatusColor(assignment['status']);
    final priorityColor = _getPriorityColor(assignment['priority']);

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
                    assignment['title'],
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    assignment['priority'].toUpperCase(),
                    style:
                        AppTextStyles.bodySmall.copyWith(color: priorityColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              assignment['description'],
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.gray600),
                const SizedBox(width: 4),
                Text(assignment['site'],
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
                const SizedBox(width: AppConstants.defaultPadding),
                Icon(Icons.people_outline, size: 16, color: AppColors.gray600),
                const SizedBox(width: 4),
                Text('${assignment['assignedTo'].length} assigned',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.gray600)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: assignment['progress'],
                        backgroundColor: AppColors.gray200,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                      const SizedBox(height: 4),
                      Text('${(assignment['progress'] * 100).toInt()}%',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        assignment['status'].toUpperCase(),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: statusColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${_formatDate(assignment['dueDate'])}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _viewAssignmentDetails(assignment),
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () => _editAssignment(assignment),
                  child: const Text('Edit'),
                ),
                if (assignment['status'] == 'active')
                  TextButton(
                    onPressed: () => _markAsCompleted(assignment['id']),
                    child: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, String subtitle, Color color) {
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
                Text(value,
                    style: AppTextStyles.heading3.copyWith(color: color)),
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

  Widget _buildPerformersList() {
    final performers = [
      {'name': 'Sarah Johnson', 'completed': 12, 'rate': '95%'},
      {'name': 'John Smith', 'completed': 10, 'rate': '88%'},
      {'name': 'Mike Wilson', 'completed': 8, 'rate': '82%'},
    ];

    return Column(
      children: performers.map((performer) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                performer['name']
                    .toString()
                    .split(' ')
                    .map((n) => n[0])
                    .join(''),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            title: Text(performer['name'].toString()),
            subtitle: Text('${performer['completed']} assignments completed'),
            trailing: Text(
              performer['rate'].toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getFilteredAssignments() {
    if (_selectedFilter == 'All') {
      return _assignments;
    }
    return _assignments
        .where((a) => a['status'] == _selectedFilter.toLowerCase())
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.primaryBlue;
      case 'completed':
        return AppColors.accentGreen;
      case 'overdue':
        return AppColors.errorRed;
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
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Overdue';
    }
  }

  void _createNewAssignment() {
    // Navigate to create assignment page
    Navigator.pushNamed(context, '/admin/assignment/create');
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Assignments'),
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

  void _showAdvancedFilters() {
    // Show advanced filter options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Advanced Filters', style: AppTextStyles.heading4),
            const SizedBox(height: AppConstants.defaultPadding),
            // Add filter options here
            const Text('Filter options will be implemented here'),
          ],
        ),
      ),
    );
  }

  void _viewAssignmentDetails(Map<String, dynamic> assignment) {
    Navigator.pushNamed(context, '/admin/assignment/details',
        arguments: assignment);
  }

  void _editAssignment(Map<String, dynamic> assignment) {
    Navigator.pushNamed(context, '/admin/assignment/edit',
        arguments: assignment);
  }

  void _markAsCompleted(String assignmentId) {
    setState(() {
      final index = _assignments.indexWhere((a) => a['id'] == assignmentId);
      if (index != -1) {
        _assignments[index]['status'] = 'completed';
        _assignments[index]['progress'] = 1.0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment marked as completed'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }
}
