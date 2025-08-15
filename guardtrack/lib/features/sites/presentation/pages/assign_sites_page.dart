import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/models/user_model.dart';

import '../../../../features/attendance/presentation/bloc/assigned_sites_bloc.dart';

enum SiteFilter { all, assigned, unassigned, nearby, active, inactive }

class AssignSitesPage extends StatefulWidget {
  final UserModel user;

  const AssignSitesPage({
    super.key,
    required this.user,
  });

  @override
  State<AssignSitesPage> createState() => _AssignSitesPageState();
}

class _AssignSitesPageState extends State<AssignSitesPage> {
  final TextEditingController _searchController = TextEditingController();
  SiteFilter _currentFilter = SiteFilter.all;
  Position? _currentPosition;
  List<SiteModel> _allSites = [];

  @override
  void initState() {
    super.initState();
    _loadSites();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSites() {
    context.read<AssignedSitesBloc>().add(LoadAllSites());
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle location error
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildSitesList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('All Sites'),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: _loadSites,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search sites by name or address...',
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
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SiteFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.smallPadding),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = filter;
                });
                _applyFilters();
              },
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
              checkmarkColor: AppColors.primaryBlue,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSitesList() {
    return BlocBuilder<AssignedSitesBloc, AssignedSitesState>(
      builder: (context, state) {
        if (state is AssignedSitesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is AssignedSitesError) {
          return _buildErrorState(state.message);
        }

        if (state is AssignedSitesLoaded) {
          _allSites = state.allSites ?? [];
          final filteredSites = _getFilteredSites();

          if (filteredSites.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSites(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: filteredSites.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppConstants.defaultPadding),
              itemBuilder: (context, index) {
                final site = filteredSites[index];
                return _buildSiteCard(site);
              },
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildSiteCard(SiteModel site) {
    final isAssigned = site.assignedGuardIds?.contains(widget.user.id) ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSiteHeader(site, isAssigned),
            const SizedBox(height: AppConstants.smallPadding),
            _buildSiteDetails(site),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildSiteActions(site, isAssigned),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteHeader(SiteModel site, bool isAssigned) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                site.name,
                style: AppTextStyles.heading4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (site.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  site.description!,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        StatusBadge(
          status: isAssigned ? StatusType.verified : StatusType.pending,
          customText: isAssigned ? 'Assigned' : 'Available',
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildSiteDetails(SiteModel site) {
    final distance = _calculateDistance(site);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.gray500,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                site.address,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (distance != null) ...[
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Icon(
                Icons.near_me_outlined,
                size: 16,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDistance(distance)} away',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
        if (site.contactPerson != null) ...[
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                site.contactPerson!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSiteActions(SiteModel site, bool isAssigned) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'View Details',
            onPressed: () => _viewSiteDetails(site),
            type: ButtonType.outline,
            size: ButtonSize.small,
            icon: Icons.info_outline,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: CustomButton(
            text: isAssigned ? 'Unassign' : 'Assign',
            onPressed: () => _toggleAssignment(site, isAssigned),
            type: isAssigned ? ButtonType.secondary : ButtonType.primary,
            size: ButtonSize.small,
            icon: isAssigned
                ? Icons.remove_circle_outline
                : Icons.add_circle_outline,
          ),
        ),
      ],
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
            'Error Loading Sites',
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
            onPressed: _loadSites,
            type: ButtonType.outline,
            isFullWidth: false,
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Sites Found',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            _getEmptyStateMessage(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case SiteFilter.assigned:
        return 'You have no assigned sites.';
      case SiteFilter.unassigned:
        return 'All sites are already assigned.';
      case SiteFilter.nearby:
        return 'No sites found nearby.';
      case SiteFilter.active:
        return 'No active sites found.';
      case SiteFilter.inactive:
        return 'No inactive sites found.';
      default:
        return 'No sites available.';
    }
  }

  List<SiteModel> _getFilteredSites() {
    final filteredSites = _allSites.where((site) {
      // Apply search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          site.name.toLowerCase().contains(searchQuery) ||
          site.address.toLowerCase().contains(searchQuery);

      if (!matchesSearch) return false;

      // Apply status filter
      switch (_currentFilter) {
        case SiteFilter.assigned:
          return site.assignedGuardIds?.contains(widget.user.id) ?? false;
        case SiteFilter.unassigned:
          return !(site.assignedGuardIds?.contains(widget.user.id) ?? false);
        case SiteFilter.nearby:
          final distance = _calculateDistance(site);
          return distance != null && distance <= 5000; // 5km
        case SiteFilter.active:
          return site.isActive;
        case SiteFilter.inactive:
          return !site.isActive;
        case SiteFilter.all:
        default:
          return true;
      }
    }).toList();

    // Sort by distance if location is available
    if (_currentPosition != null) {
      filteredSites.sort((a, b) {
        final distanceA = _calculateDistance(a) ?? double.infinity;
        final distanceB = _calculateDistance(b) ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });
    }

    return filteredSites;
  }

  void _applyFilters() {
    setState(() {
      // Trigger rebuild to recompute filtered sites
    });
  }

  String _getFilterLabel(SiteFilter filter) {
    switch (filter) {
      case SiteFilter.all:
        return 'All';
      case SiteFilter.assigned:
        return 'Assigned';
      case SiteFilter.unassigned:
        return 'Available';
      case SiteFilter.nearby:
        return 'Nearby';
      case SiteFilter.active:
        return 'Active';
      case SiteFilter.inactive:
        return 'Inactive';
    }
  }

  double? _calculateDistance(SiteModel site) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      site.latitude,
      site.longitude,
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sites'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SiteFilter.values.map((filter) {
            return RadioListTile<SiteFilter>(
              title: Text(_getFilterLabel(filter)),
              value: filter,
              groupValue: _currentFilter,
              onChanged: (value) {
                setState(() {
                  _currentFilter = value!;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _viewSiteDetails(SiteModel site) {
    Navigator.of(context).pushNamed(
      '/site-details',
      arguments: site,
    );
  }

  void _toggleAssignment(SiteModel site, bool isCurrentlyAssigned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentlyAssigned ? 'Unassign Site' : 'Assign Site'),
        content: Text(
          isCurrentlyAssigned
              ? 'Are you sure you want to unassign yourself from ${site.name}?'
              : 'Are you sure you want to assign yourself to ${site.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performAssignmentToggle(site, isCurrentlyAssigned);
            },
            child: Text(isCurrentlyAssigned ? 'Unassign' : 'Assign'),
          ),
        ],
      ),
    );
  }

  void _performAssignmentToggle(SiteModel site, bool isCurrentlyAssigned) {
    // TODO: Implement actual assignment/unassignment logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCurrentlyAssigned
              ? 'Unassigned from ${site.name}'
              : 'Assigned to ${site.name}',
        ),
        backgroundColor: isCurrentlyAssigned
            ? AppColors.warningAmber
            : AppColors.accentGreen,
      ),
    );

    // Refresh the sites list
    _loadSites();
  }
}
