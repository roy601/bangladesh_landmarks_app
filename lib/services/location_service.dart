import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get current latitude and longitude as a map
  static Future<Map<String, double>?> getCurrentLatLng() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return {
        'lat': position.latitude,
        'lon': position.longitude,
      };
    }
    return null;
  }

  /// Calculate distance between two coordinates (in kilometers)
  static double calculateDistance(
      double startLat,
      double startLon,
      double endLat,
      double endLon,
      ) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    ) /
        1000; // Convert to kilometers
  }
}