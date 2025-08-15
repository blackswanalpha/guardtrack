import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

import '../../../../shared/models/attendance_model.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/models/user_model.dart';
import '../widgets/attendance_card.dart';
import '../widgets/attendance_filter_sheet.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final UserModel user;

  const AttendanceHistoryPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  AttendanceFilter _currentFilter = AttendanceFilter.all;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadAttendanceHistory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is AttendanceError) {
                  return _buildErrorState(state.message);
                }

                if (state is AttendanceHistoryLoaded) {
                  return _buildHistoryList(state.attendanceList, state.sites);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by site name or code...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', AttendanceFilter.all),
                const SizedBox(width: AppConstants.smallPadding),
                _buildFilterChip('Check-ins', AttendanceFilter.checkIn),
                const SizedBox(width: AppConstants.smallPadding),
                _buildFilterChip('Check-outs', AttendanceFilter.checkOut),
                const SizedBox(width: AppConstants.smallPadding),
                _buildFilterChip('Verified', AttendanceFilter.verified),
                const SizedBox(width: AppConstants.smallPadding),
                _buildFilterChip('Pending', AttendanceFilter.pending),
                const SizedBox(width: AppConstants.smallPadding),
                _buildDateRangeChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AttendanceFilter filter) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = selected ? filter : AttendanceFilter.all;
        });
        _applyFilters();
      },
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
    );
  }

  Widget _buildDateRangeChip() {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range, size: 16),
          const SizedBox(width: 4),
          Text(_dateRange != null
              ? '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}'
              : 'Date Range'),
        ],
      ),
      selected: _dateRange != null,
      onSelected: (_) => _selectDateRange(),
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
    );
  }

  Widget _buildHistoryList(
      List<AttendanceModel> attendanceList, Map<String, SiteModel> sites) {
    if (attendanceList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: attendanceList.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppConstants.defaultPadding),
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          final site = sites[attendance.siteId];

          return AttendanceCard(
            attendance: attendance,
            site: site,
            onTap: () => _showAttendanceDetails(attendance, site),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Attendance Records',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Your attendance history will appear here once you start checking in.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          CustomButton(
            text: 'Go to Dashboard',
            onPressed: () => Navigator.of(context).pop(),
            type: ButtonType.outline,
            isFullWidth: false,
            width: 160,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Something went wrong',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          CustomButton(
            text: 'Retry',
            onPressed: () =>
                context.read<AttendanceBloc>().add(LoadAttendanceHistory()),
            type: ButtonType.outline,
            isFullWidth: false,
            width: 120,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttendanceFilterSheet(
        currentFilter: _currentFilter,
        dateRange: _dateRange,
        onFilterChanged: (filter, dateRange) {
          setState(() {
            _currentFilter = filter;
            _dateRange = dateRange;
          });
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    context.read<AttendanceBloc>().add(
          FilterAttendanceHistory(
            searchQuery: _searchController.text,
            filter: _currentFilter,
            dateRange: _dateRange,
          ),
        );
  }

  Future<void> _handleRefresh() async {
    context.read<AttendanceBloc>().add(RefreshAttendanceHistory());
  }

  void _showAttendanceDetails(AttendanceModel attendance, SiteModel? site) {
    // TODO: Navigate to attendance details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Details for ${attendance.arrivalCode}'),
      ),
    );
  }
}

enum AttendanceFilter { all, checkIn, checkOut, verified, pending, rejected }
