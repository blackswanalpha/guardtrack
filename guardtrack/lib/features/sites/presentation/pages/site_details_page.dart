import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/models/site_model.dart';
import '../../../../shared/services/location_service.dart';
import '../widgets/site_map_widget.dart';

class SiteDetailsPage extends StatefulWidget {
  final SiteModel site;
  final Position? currentPosition;

  const SiteDetailsPage({
    super.key,
    required this.site,
    this.currentPosition,
  });

  @override
  State<SiteDetailsPage> createState() => _SiteDetailsPageState();
}

class _SiteDetailsPageState extends State<SiteDetailsPage> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition;
    if (_currentPosition == null) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final isWithinRange = _isWithinRange(distance);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(widget.site.name),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: _handleRefreshLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(isWithinRange, distance),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildMapCard(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildSiteInfoCard(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildLocationInfoCard(distance),
            const SizedBox(height: AppConstants.largePadding),
            _buildActionButtons(isWithinRange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isWithinRange, double? distance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Check-in Status',
                    style: AppTextStyles.heading4,
                  ),
                ),
                StatusBadge(
                  status: isWithinRange ? StatusType.verified : StatusType.pending,
                  customText: isWithinRange ? 'In Range' : 'Out of Range',
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: isWithinRange 
                    ? AppColors.accentGreen.withOpacity(0.1)
                    : AppColors.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: isWithinRange 
                      ? AppColors.accentGreen.withOpacity(0.3)
                      : AppColors.warningAmber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isWithinRange ? Icons.check_circle : Icons.warning,
                    color: isWithinRange ? AppColors.accentGreen : AppColors.warningAmber,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWithinRange 
                              ? 'You are within the check-in area'
                              : 'Move closer to the site to check in',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isWithinRange ? AppColors.accentGreen : AppColors.warningDark,
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Distance: ${_formatDistance(distance)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Location',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SiteMapWidget(
              site: widget.site,
              currentPosition: _currentPosition,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Information',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Address',
              value: widget.site.address,
            ),
            if (widget.site.description != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              _buildInfoRow(
                icon: Icons.description,
                label: 'Description',
                value: widget.site.description!,
              ),
            ],
            const SizedBox(height: AppConstants.smallPadding),
            _buildInfoRow(
              icon: Icons.radio_button_unchecked,
              label: 'Check-in Radius',
              value: '${widget.site.allowedRadius.toInt()} meters',
            ),
            if (widget.site.contactPerson != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              _buildInfoRow(
                icon: Icons.person,
                label: 'Contact Person',
                value: widget.site.contactPerson!,
              ),
            ],
            if (widget.site.contactPhone != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Contact Phone',
                value: widget.site.contactPhone!,
                isClickable: true,
                onTap: () => _handleCallContact(widget.site.contactPhone!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(double? distance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_currentPosition != null) ...[
              _buildInfoRow(
                icon: Icons.my_location,
                label: 'Your Location',
                value: '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: AppConstants.smallPadding),
              _buildInfoRow(
                icon: Icons.speed,
                label: 'GPS Accuracy',
                value: '±${_currentPosition!.accuracy.toStringAsFixed(1)}m',
              ),
              if (distance != null) ...[
                const SizedBox(height: AppConstants.smallPadding),
                _buildInfoRow(
                  icon: Icons.straighten,
                  label: 'Distance to Site',
                  value: _formatDistance(distance),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Text(
                      'Location not available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.gray500,
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isClickable ? AppColors.primaryBlue : AppColors.textDark,
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isWithinRange) {
    return Column(
      children: [
        CustomButton(
          text: 'Check In at Site',
          icon: Icons.location_on,
          onPressed: isWithinRange ? _handleCheckIn : null,
          type: ButtonType.primary,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        CustomButton(
          text: 'Get Directions',
          icon: Icons.directions,
          onPressed: _handleGetDirections,
          type: ButtonType.outline,
        ),
      ],
    );
  }

  double? _calculateDistance() {
    if (_currentPosition == null) return null;
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.site.latitude,
      widget.site.longitude,
    );
  }

  bool _isWithinRange(double? distance) {
    if (distance == null) return false;
    return distance <= widget.site.allowedRadius;
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _handleRefreshLocation() {
    _getCurrentLocation();
  }

  void _handleCheckIn() {
    // TODO: Navigate to check-in flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check-in at ${widget.site.name} coming soon'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _handleGetDirections() {
    // TODO: Open maps app with directions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Directions functionality coming soon'),
      ),
    );
  }

  void _handleCallContact(String phoneNumber) {
    // TODO: Make phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call $phoneNumber functionality coming soon'),
      ),
    );
  }
}
