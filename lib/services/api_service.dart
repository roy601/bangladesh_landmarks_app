import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/landmark_model.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Fetch all landmarks
  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final response = await _dio.get('');

      if (response.statusCode == 200) {
        if (response.data is List) {
          List<Landmark> landmarks = (response.data as List)
              .map((json) => Landmark.fromJson(json))
              .toList();
          return landmarks;
        }
      }
      throw Exception('Failed to load landmarks');
    } catch (e) {
      print('Error fetching landmarks: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Create a new landmark
  Future<bool> createLandmark({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.baseUrl),
      );

      // Add fields
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      // Add image if provided
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: 'landmark_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create landmark: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error creating landmark: $e');
      return false;
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
    try {
      if (imageFile != null) {
        // If image is provided, use multipart
        var request = http.MultipartRequest(
          'POST', // Some servers use POST for file uploads
          Uri.parse(AppConstants.baseUrl),
        );

        request.fields['id'] = id.toString();
        request.fields['title'] = title;
        request.fields['lat'] = lat.toString();
        request.fields['lon'] = lon.toString();
        request.fields['_method'] = 'PUT'; // Method override

        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: 'landmark_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        return response.statusCode == 200;
      } else {
        // Without image, use form-encoded PUT
        final response = await _dio.put(
          '',
          data: {
            'id': id,
            'title': title,
            'lat': lat,
            'lon': lon,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

        return response.statusCode == 200;
      }
    } catch (e) {
      print('Error updating landmark: $e');
      return false;
    }
  }

  /// Delete a landmark
  Future<bool> deleteLandmark(int id) async {
    try {
      final response = await _dio.delete(
        '',
        data: {'id': id},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting landmark: $e');
      return false;
    }
  }
}
