import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/errors/failures.dart';
import '../models/site_model.dart';
import 'location_service.dart';

enum GeofenceStatus { inside, outside, unknown }

class GeofenceEvent {
  final String siteId;
  final GeofenceStatus status;
  final Position position;
  final DateTime timestamp;
  final double distance;

  const GeofenceEvent({
    required this.siteId,
    required this.status,
    required this.position,
    required this.timestamp,
    required this.distance,
  });
}

class GeofencingService {
  static final GeofencingService _instance = GeofencingService._internal();
  factory GeofencingService() => _instance;
  GeofencingService._internal();

  final LocationService _locationService = LocationService();
  final Map<String, SiteModel> _monitoredSites = {};
  final Map<String, GeofenceStatus> _siteStatuses = {};

  StreamController<GeofenceEvent>? _geofenceController;
  StreamSubscription<Position>? _positionSubscription;

  // Get geofence events stream
  Stream<GeofenceEvent> get geofenceEvents {
    _geofenceController ??= StreamController<GeofenceEvent>.broadcast();
    return _geofenceController!.stream;
  }

  // Check if a position is within a geofence
  Future<bool> isWithinGeofence(
    Position position,
    double targetLatitude,
    double targetLongitude,
    double radius,
  ) async {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radius;
  }

  // Add site to monitoring
  void addSiteToMonitoring(SiteModel site) {
    _monitoredSites[site.id] = site;
    _siteStatuses[site.id] = GeofenceStatus.unknown;
  }

  // Remove site from monitoring
  void removeSiteFromMonitoring(String siteId) {
    _monitoredSites.remove(siteId);
    _siteStatuses.remove(siteId);
  }

  // Clear all monitored sites
  void clearMonitoredSites() {
    _monitoredSites.clear();
    _siteStatuses.clear();
  }

  // Start geofence monitoring
  Future<void> startMonitoring({
    Duration? updateInterval,
    int distanceFilter = 10,
  }) async {
    try {
      if (_positionSubscription != null) {
        await stopMonitoring();
      }

      await _locationService.startPositionTracking(
        interval: updateInterval,
        distanceFilter: distanceFilter,
        onPositionUpdate: _handlePositionUpdate,
        onError: _handleLocationError,
      );
    } catch (e) {
      throw const GeofenceFailure(
          message: 'Failed to start geofence monitoring');
    }
  }

  // Stop geofence monitoring
  Future<void> stopMonitoring() async {
    _locationService.stopPositionTracking();
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // Check if position is within site geofence
  bool isWithinSiteGeofence(Position position, SiteModel site) {
    return _locationService.isWithinGeofence(
      position,
      site.latitude,
      site.longitude,
      site.allowedRadius,
    );
  }

  // Get distance to site
  double getDistanceToSite(Position position, SiteModel site) {
    return _locationService.calculateDistance(
      position.latitude,
      position.longitude,
      site.latitude,
      site.longitude,
    );
  }

  // Check geofence status for specific site
  Future<GeofenceStatus> checkSiteGeofenceStatus(
    String siteId, {
    Position? position,
  }) async {
    try {
      final site = _monitoredSites[siteId];
      if (site == null) {
        throw const GeofenceFailure(
            message: 'Site not found in monitoring list');
      }

      final currentPosition =
          position ?? await _locationService.getCurrentPosition();

      final isInside = isWithinSiteGeofence(currentPosition, site);
      final status = isInside ? GeofenceStatus.inside : GeofenceStatus.outside;

      _siteStatuses[siteId] = status;

      return status;
    } catch (e) {
      throw const GeofenceFailure(message: 'Failed to check geofence status');
    }
  }

  // Get current status for all monitored sites
  Future<Map<String, GeofenceStatus>> getAllSiteStatuses({
    Position? position,
  }) async {
    try {
      final currentPosition =
          position ?? await _locationService.getCurrentPosition();
      final statuses = <String, GeofenceStatus>{};

      for (final entry in _monitoredSites.entries) {
        final siteId = entry.key;
        final site = entry.value;

        final isInside = isWithinSiteGeofence(currentPosition, site);
        final status =
            isInside ? GeofenceStatus.inside : GeofenceStatus.outside;

        statuses[siteId] = status;
        _siteStatuses[siteId] = status;
      }

      return statuses;
    } catch (e) {
      throw const GeofenceFailure(message: 'Failed to get all site statuses');
    }
  }

  // Get nearest site
  Future<SiteModel?> getNearestSite({Position? position}) async {
    try {
      if (_monitoredSites.isEmpty) return null;

      final currentPosition =
          position ?? await _locationService.getCurrentPosition();

      SiteModel? nearestSite;
      double nearestDistance = double.infinity;

      for (final site in _monitoredSites.values) {
        final distance = getDistanceToSite(currentPosition, site);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestSite = site;
        }
      }

      return nearestSite;
    } catch (e) {
      throw const GeofenceFailure(message: 'Failed to get nearest site');
    }
  }

  // Get sites within range
  Future<List<SiteModel>> getSitesWithinRange(
    double rangeInMeters, {
    Position? position,
  }) async {
    try {
      final currentPosition =
          position ?? await _locationService.getCurrentPosition();
      final sitesInRange = <SiteModel>[];

      for (final site in _monitoredSites.values) {
        final distance = getDistanceToSite(currentPosition, site);
        if (distance <= rangeInMeters) {
          sitesInRange.add(site);
        }
      }

      return sitesInRange;
    } catch (e) {
      throw const GeofenceFailure(message: 'Failed to get sites within range');
    }
  }

  // Validate check-in location
  Future<bool> validateCheckInLocation(
    String siteId, {
    Position? position,
    double? customRadius,
  }) async {
    try {
      final site = _monitoredSites[siteId];
      if (site == null) {
        throw const GeofenceFailure(message: 'Site not found for validation');
      }

      final currentPosition =
          position ?? await _locationService.getAccuratePosition();

      // Use custom radius if provided, otherwise use site's allowed radius
      final allowedRadius = customRadius ?? site.allowedRadius;

      final distance = getDistanceToSite(currentPosition, site);
      return distance <= allowedRadius;
    } catch (e) {
      throw const GeofenceFailure(
          message: 'Failed to validate check-in location');
    }
  }

  // Handle position updates
  void _handlePositionUpdate(Position position) {
    for (final entry in _monitoredSites.entries) {
      final siteId = entry.key;
      final site = entry.value;

      final isInside = isWithinSiteGeofence(position, site);
      final newStatus =
          isInside ? GeofenceStatus.inside : GeofenceStatus.outside;
      final previousStatus = _siteStatuses[siteId] ?? GeofenceStatus.unknown;

      // Only emit event if status changed
      if (newStatus != previousStatus) {
        _siteStatuses[siteId] = newStatus;

        final distance = getDistanceToSite(position, site);

        final event = GeofenceEvent(
          siteId: siteId,
          status: newStatus,
          position: position,
          timestamp: DateTime.now(),
          distance: distance,
        );

        _geofenceController?.add(event);
      }
    }
  }

  // Handle location errors
  void _handleLocationError(Exception error) {
    // Log error or handle as needed
    // Could emit error events if needed
  }

  // Get monitored sites
  Map<String, SiteModel> get monitoredSites =>
      Map.unmodifiable(_monitoredSites);

  // Get current site statuses
  Map<String, GeofenceStatus> get currentStatuses =>
      Map.unmodifiable(_siteStatuses);

  // Check if monitoring is active
  bool get isMonitoring => _locationService.isTracking;

  // Dispose resources
  void dispose() {
    stopMonitoring();
    _geofenceController?.close();
    _geofenceController = null;
  }
}
