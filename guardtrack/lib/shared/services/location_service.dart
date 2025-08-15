import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Service for handling GPS location tracking, geofencing, and location-based operations.
///
/// This service provides comprehensive location functionality including:
/// - GPS permission management
/// - Real-time location tracking
/// - Geofencing validation
/// - Distance calculations
/// - Location accuracy validation
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;

  // Initialize location service
  Future<void> initialize() async {
    // Initialization logic if needed
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Alias for isLocationServiceEnabled for consistency
  Future<bool> isLocationEnabled() async {
    return await isLocationServiceEnabled();
  }

  // Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // Check and request all necessary permissions
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw LocationException(
          message:
              'Location services are disabled. Please enable location services.',
        );
      }

      // Check location permission
      LocationPermission permission = await checkLocationPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == LocationPermission.denied) {
        throw LocationPermissionException(
          message: 'Location permission denied. Please grant location access.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionException(
          message:
              'Location permission permanently denied. Please enable in settings.',
        );
      }

      return true;
    } catch (e) {
      if (e is LocationException || e is LocationPermissionException) {
        rethrow;
      }
      throw LocationException(message: 'Error checking permissions: $e');
    }
  }

  // Get current position
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout,
  }) async {
    try {
      await checkAndRequestPermissions();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout ?? AppConstants.locationTimeout,
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      if (e is LocationException || e is LocationPermissionException) {
        rethrow;
      }
      throw LocationException(message: 'Failed to get current position: $e');
    }
  }

  // Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownPosition = position;
      }
      return position;
    } catch (e) {
      throw LocationException(message: 'Failed to get last known position: $e');
    }
  }

  // Start listening to position updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration? interval,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: interval ?? AppConstants.locationUpdateInterval,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Start position tracking
  Future<void> startPositionTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? interval,
    required Function(Position) onPositionUpdate,
    Function(Exception)? onError,
  }) async {
    try {
      await checkAndRequestPermissions();

      _positionStreamSubscription?.cancel();

      _positionStreamSubscription = getPositionStream(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        interval: interval,
      ).listen(
        (position) {
          _lastKnownPosition = position;
          onPositionUpdate(position);
        },
        onError: (error) {
          final exception = LocationException(
            message: 'Position tracking error: $error',
          );
          onError?.call(exception);
        },
      );
    } catch (e) {
      if (e is LocationException || e is LocationPermissionException) {
        rethrow;
      }
      throw LocationException(message: 'Failed to start position tracking: $e');
    }
  }

  // Stop position tracking
  void stopPositionTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if position is within geofence
  bool isWithinGeofence(
    Position currentPosition,
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distance <= radiusInMeters;
  }

  // Validate position accuracy
  bool isPositionAccurate(Position position, {double? requiredAccuracy}) {
    final accuracy = requiredAccuracy ?? AppConstants.defaultLocationAccuracy;
    return position.accuracy <= accuracy;
  }

  // Get position with accuracy validation
  Future<Position> getAccuratePosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    double? requiredAccuracy,
    Duration? timeout,
    int maxRetries = 3,
  }) async {
    int retries = 0;

    while (retries < maxRetries) {
      try {
        final position = await getCurrentPosition(
          accuracy: accuracy,
          timeout: timeout,
        );

        if (isPositionAccurate(position, requiredAccuracy: requiredAccuracy)) {
          return position;
        }

        retries++;
        if (retries < maxRetries) {
          // Wait before retry
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    throw const LocationAccuracyFailure(
      message: 'Could not get accurate position after max attempts',
    );
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      throw LocationException(message: 'Failed to open location settings: $e');
    }
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      throw LocationException(message: 'Failed to open app settings: $e');
    }
  }

  // Get cached position
  Position? get lastKnownPosition => _lastKnownPosition;

  // Check if currently tracking
  bool get isTracking => _positionStreamSubscription != null;

  // Dispose resources
  void dispose() {
    stopPositionTracking();
  }
}
