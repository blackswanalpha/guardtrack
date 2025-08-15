import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardtrack/shared/services/location_service.dart';

// Mock classes
class MockGeolocator extends Mock implements GeolocatorPlatform {}

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    group('calculateDistance', () {
      test('should calculate correct distance between two points', () {
        // Arrange
        const lat1 = -1.2921; // Nairobi
        const lon1 = 36.8219;
        const lat2 = -1.2676; // Westlands
        const lon2 = 36.8108;

        // Act
        final distance =
            locationService.calculateDistance(lat1, lon1, lat2, lon2);

        // Assert
        expect(distance, greaterThan(0));
        expect(distance, lessThan(5000)); // Should be less than 5km
      });

      test('should return 0 for same coordinates', () {
        // Arrange
        const lat = -1.2921;
        const lon = 36.8219;

        // Act
        final distance = locationService.calculateDistance(lat, lon, lat, lon);

        // Assert
        expect(distance, equals(0));
      });
    });

    group('isWithinGeofence', () {
      test('should return true when position is within geofence', () {
        // Arrange
        final position = Position(
          latitude: -1.2921,
          longitude: 36.8219,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        const targetLat = -1.2921;
        const targetLon = 36.8219;
        const radius = 100.0;

        // Act
        final isWithin = locationService.isWithinGeofence(
          position,
          targetLat,
          targetLon,
          radius,
        );

        // Assert
        expect(isWithin, isTrue);
      });

      test('should return false when position is outside geofence', () {
        // Arrange
        final position = Position(
          latitude: -1.2921,
          longitude: 36.8219,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        const targetLat = -1.3000; // Far away
        const targetLon = 36.9000;
        const radius = 100.0;

        // Act
        final isWithin = locationService.isWithinGeofence(
          position,
          targetLat,
          targetLon,
          radius,
        );

        // Assert
        expect(isWithin, isFalse);
      });
    });

    group('isPositionAccurate', () {
      test('should return true for accurate position', () {
        // Arrange
        final position = Position(
          latitude: -1.2921,
          longitude: 36.8219,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        // Act
        final isAccurate = locationService.isPositionAccurate(position);

        // Assert
        expect(isAccurate, isTrue);
      });

      test('should return false for inaccurate position', () {
        // Arrange
        final position = Position(
          latitude: -1.2921,
          longitude: 36.8219,
          timestamp: DateTime.now(),
          accuracy: 100.0, // Poor accuracy
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        // Act
        final isAccurate = locationService.isPositionAccurate(position);

        // Assert
        expect(isAccurate, isFalse);
      });

      test('should use custom accuracy threshold', () {
        // Arrange
        final position = Position(
          latitude: -1.2921,
          longitude: 36.8219,
          timestamp: DateTime.now(),
          accuracy: 30.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        // Act
        final isAccurate = locationService.isPositionAccurate(
          position,
          requiredAccuracy: 20.0,
        );

        // Assert
        expect(isAccurate, isFalse);
      });
    });

    tearDown(() {
      locationService.dispose();
    });
  });
}
