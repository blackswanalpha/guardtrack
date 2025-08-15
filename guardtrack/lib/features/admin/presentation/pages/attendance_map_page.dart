import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class AttendanceMapPage extends StatefulWidget {
  const AttendanceMapPage({super.key});

  @override
  State<AttendanceMapPage> createState() => _AttendanceMapPageState();
}

class _AttendanceMapPageState extends State<AttendanceMapPage> {
  bool _showOnlineOnly = true;
  String _selectedTimeFilter = 'Today';
  final List<String> _timeFilters = ['Today', 'This Week', 'This Month'];

  // Mock guard locations
  final List<Map<String, dynamic>> _guardLocations = [
    {
      'id': '1',
      'name': 'John Smith',
      'site': 'Site Alpha',
      'status': 'online',
      'lastSeen': '2 min ago',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'site': 'Site Beta',
      'status': 'online',
      'lastSeen': '5 min ago',
      'lat': 37.7849,
      'lng': -122.4094,
    },
    {
      'id': '3',
      'name': 'Mike Wilson',
      'site': 'Site Gamma',
      'status': 'offline',
      'lastSeen': '2 hours ago',
      'lat': 37.7649,
      'lng': -122.4294,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Stack(
              children: [
                _buildMapPlaceholder(),
                _buildGuardsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "attendance_map_fab",
        onPressed: _refreshLocations,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.refresh, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: Text(
        'Live Guard Tracking',
        style: AppTextStyles.heading3.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.white),
          onPressed: _showMapSettings,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeFilter,
                  decoration: InputDecoration(
                    labelText: 'Time Range',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                  ),
                  items: _timeFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              FilterChip(
                label: const Text('Online Only'),
                selected: _showOnlineOnly,
                onSelected: (selected) {
                  setState(() {
                    _showOnlineOnly = selected;
                  });
                },
                selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                checkmarkColor: AppColors.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final onlineGuards =
        _guardLocations.where((g) => g['status'] == 'online').length;
    final totalGuards = _guardLocations.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            'Online',
            onlineGuards.toString(),
            AppColors.accentGreen,
            Icons.circle,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatChip(
            'Offline',
            (totalGuards - onlineGuards).toString(),
            AppColors.errorRed,
            Icons.circle,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatChip(
            'Total',
            totalGuards.toString(),
            AppColors.primaryBlue,
            Icons.people,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.gray100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Interactive Map View',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Google Maps integration pending',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Map Features:',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                ...[
                  '• Real-time guard locations',
                  '• Site boundaries and geofences',
                  '• Movement tracking and history',
                  '• Clustering for multiple guards',
                  '• Custom markers for different statuses',
                ]
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            feature,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.gray600),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardsList() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        final filteredGuards = _showOnlineOnly
            ? _guardLocations.where((g) => g['status'] == 'online').toList()
            : _guardLocations;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppConstants.borderRadius * 2),
              topRight: Radius.circular(AppConstants.borderRadius * 2),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(
                    vertical: AppConstants.smallPadding),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Guards (${filteredGuards.length})',
                      style: AppTextStyles.heading4,
                    ),
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () {
                        // Switch to list view
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  itemCount: filteredGuards.length,
                  itemBuilder: (context, index) {
                    final guard = filteredGuards[index];
                    return _buildGuardCard(guard);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuardCard(Map<String, dynamic> guard) {
    final isOnline = guard['status'] == 'online';
    final statusColor = isOnline ? AppColors.accentGreen : AppColors.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                guard['name'].split(' ').map((n) => n[0]).join(''),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(guard['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guard['site']),
            Text(
              'Last seen: ${guard['lastSeen']}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.location_on, color: AppColors.primaryBlue),
              onPressed: () => _centerOnGuard(guard),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showGuardOptions(guard),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshLocations() {
    // TODO: Implement location refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guard locations refreshed'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _showMapSettings() {
    // TODO: Show map settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Settings'),
        content:
            const Text('Map configuration options will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _centerOnGuard(Map<String, dynamic> guard) {
    // TODO: Center map on guard location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Centering on ${guard['name']}'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showGuardOptions(Map<String, dynamic> guard) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to guard profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // Send message to guard
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () {
                Navigator.pop(context);
                // View guard location history
              },
            ),
          ],
        ),
      ),
    );
  }
}
