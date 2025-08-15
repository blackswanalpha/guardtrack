import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../pages/attendance_history_page.dart';

class AttendanceFilterSheet extends StatefulWidget {
  final AttendanceFilter currentFilter;
  final DateTimeRange? dateRange;
  final Function(AttendanceFilter filter, DateTimeRange? dateRange) onFilterChanged;

  const AttendanceFilterSheet({
    super.key,
    required this.currentFilter,
    this.dateRange,
    required this.onFilterChanged,
  });

  @override
  State<AttendanceFilterSheet> createState() => _AttendanceFilterSheetState();
}

class _AttendanceFilterSheetState extends State<AttendanceFilterSheet> {
  late AttendanceFilter _selectedFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedDateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius * 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildFilterOptions(),
          _buildDateRangeSection(),
          _buildActionButtons(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smallPadding),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.gray300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Text(
            'Filter Attendance',
            style: AppTextStyles.heading3,
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear All',
              style: AppTextStyles.link,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              _buildFilterChip('All', AttendanceFilter.all),
              _buildFilterChip('Check-ins', AttendanceFilter.checkIn),
              _buildFilterChip('Check-outs', AttendanceFilter.checkOut),
              _buildFilterChip('Verified', AttendanceFilter.verified),
              _buildFilterChip('Pending', AttendanceFilter.pending),
              _buildFilterChip('Rejected', AttendanceFilter.rejected),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AttendanceFilter filter) {
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? filter : AttendanceFilter.all;
        });
      },
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: isSelected ? AppColors.primaryBlue : AppColors.textDark,
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray300),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                          : 'Select date range',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _selectedDateRange != null 
                            ? AppColors.textDark 
                            : AppColors.gray500,
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.gray500,
                        size: 20,
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              type: ButtonType.outline,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: CustomButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
              type: ButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
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
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = AttendanceFilter.all;
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_selectedFilter, _selectedDateRange);
    Navigator.of(context).pop();
  }
}
