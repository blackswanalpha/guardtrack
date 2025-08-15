import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/site_model.dart';

class SiteMapWidget extends StatelessWidget {
  final SiteModel site;
  final Position? currentPosition;
  final double height;

  const SiteMapWidget({
    super.key,
    required this.site,
    this.currentPosition,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.gray300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Stack(
          children: [
            // Map placeholder - replace with actual map implementation
            _buildMapPlaceholder(),
            
            // Map controls overlay
            Positioned(
              top: AppConstants.smallPadding,
              right: AppConstants.smallPadding,
              child: _buildMapControls(context),
            ),
            
            // Location info overlay
            Positioned(
              bottom: AppConstants.smallPadding,
              left: AppConstants.smallPadding,
              right: AppConstants.smallPadding,
              child: _buildLocationInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.accentGreen.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern to simulate map
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),
          
          // Site marker
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    site.name,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Current position marker (if available)
          if (currentPosition != null)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          
          // Geofence radius indicator
          Center(
            child: Container(
              width: _getRadiusDisplaySize(),
              height: _getRadiusDisplaySize(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.5),
                  width: 2,
                ),
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls(BuildContext context) {
    return Column(
      children: [
        _buildControlButton(
          icon: Icons.zoom_in,
          onPressed: () => _handleZoomIn(context),
        ),
        const SizedBox(height: 4),
        _buildControlButton(
          icon: Icons.zoom_out,
          onPressed: () => _handleZoomOut(context),
        ),
        const SizedBox(height: 4),
        _buildControlButton(
          icon: Icons.my_location,
          onPressed: () => _handleCenterOnLocation(context),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: AppColors.gray700,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              'Check-in radius: ${site.allowedRadius.toInt()}m',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ),
          if (currentPosition != null) ...[
            Icon(
              Icons.gps_fixed,
              size: 16,
              color: AppColors.accentGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'GPS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _getRadiusDisplaySize() {
    // Scale the radius for display purposes
    // This is a simplified calculation - in a real map, this would be based on zoom level
    final baseSize = site.allowedRadius / 2;
    return (baseSize).clamp(60.0, 120.0);
  }

  void _handleZoomIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zoom in functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleZoomOut(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zoom out functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleCenterOnLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Center on location functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray300.withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSize = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
