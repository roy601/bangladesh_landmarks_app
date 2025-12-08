import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/landmark_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class LandmarkProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;

  List<Landmark> _landmarks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;

  // Getters
  List<Landmark> get landmarks => _landmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineMode => _isOfflineMode;

  /// Fetch all landmarks from API
  Future<void> fetchLandmarks({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try fetching from API
      final landmarks = await _apiService.fetchLandmarks();
      _landmarks = landmarks;
      _isOfflineMode = false;

      // Save to local database (BONUS: offline caching)
      await _dbService.deleteAllLandmarks();
      await _dbService.insertLandmarks(landmarks);

      _errorMessage = null;
    } catch (e) {
      print('Error fetching from API: $e');

      // Fallback to local database
      try {
        _landmarks = await _dbService.getLandmarks();
        _isOfflineMode = true;
        _errorMessage = 'Showing cached data (offline mode)';
      } catch (dbError) {
        _errorMessage = 'Failed to load landmarks';
        _landmarks = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new landmark
  Future<bool> addLandmark({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );

      if (success) {
        // Refresh landmarks after adding
        await fetchLandmarks();
        return true;
      } else {
        _errorMessage = 'Failed to add landmark';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing landmark
  Future<bool> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.updateLandmark(
        id: id,
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );

      if (success) {
        // Refresh landmarks after updating
        await fetchLandmarks();
        return true;
      } else {
        _errorMessage = 'Failed to update landmark';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a landmark
  Future<bool> deleteLandmark(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteLandmark(id);

      if (success) {
        // Remove from local list
        _landmarks.removeWhere((landmark) => landmark.id == id);

        // Remove from database
        await _dbService.deleteLandmark(id);

        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete landmark';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get current location
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      return await LocationService.getCurrentLatLng();
    } catch (e) {
      _errorMessage = 'Failed to get location: $e';
      notifyListeners();
      return null;
    }
  }

  /// Search landmarks by title
  List<Landmark> searchLandmarks(String query) {
    if (query.isEmpty) return _landmarks;

    return _landmarks
        .where((landmark) =>
            landmark.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get landmarks sorted by distance from a point
  List<Landmark> getLandmarksSortedByDistance(double lat, double lon) {
    final landmarksWithDistance = _landmarks.map((landmark) {
      final distance = LocationService.calculateDistance(
        lat,
        lon,
        landmark.lat,
        landmark.lon,
      );
      return {'landmark': landmark, 'distance': distance};
    }).toList();

    landmarksWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    return landmarksWithDistance
        .map((item) => item['landmark'] as Landmark)
        .toList();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchLandmarks(forceRefresh: true);
  }
}
