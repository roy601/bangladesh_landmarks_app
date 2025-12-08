import 'dart:io';
import 'package:dio/dio.dart';
import '../models/landmark_model.dart';
import '../utils/constants.dart';

class ApiService {
  Dio _getDio() {
    final dio = Dio();
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add logging interceptor
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  }

  /// Fetch all landmarks
  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final dio = _getDio();
      final response = await dio.get('');

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
      final dio = _getDio();

      Map<String, dynamic> formDataMap = {
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
      };

      // Add image if provided
      if (imageFile != null) {
        // Create a fresh copy of the file bytes
        final bytes = await imageFile.readAsBytes();
        String fileName = 'landmark_${DateTime.now().millisecondsSinceEpoch}.jpg';

        formDataMap['image'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        '',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Landmark created successfully: ${response.data}');
        return true;
      } else {
        print('Failed to create landmark: ${response.statusCode}');
        print('Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error creating landmark: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
      }
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
      final dio = _getDio();

      if (imageFile != null) {
        // With image - use FormData with fresh bytes
        Map<String, dynamic> formDataMap = {
          'id': id.toString(),
          'title': title,
          'lat': lat.toString(),
          'lon': lon.toString(),
        };

        // Create a fresh copy of the file bytes
        final bytes = await imageFile.readAsBytes();
        String fileName = 'landmark_${DateTime.now().millisecondsSinceEpoch}.jpg';

        formDataMap['image'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );

        FormData formData = FormData.fromMap(formDataMap);

        final response = await dio.put(
          '',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        print('Update response status: ${response.statusCode}');
        print('Update response data: ${response.data}');

        return response.statusCode == 200;
      } else {
        // Without image - use form-urlencoded
        final response = await dio.put(
          '',
          data: {
            'id': id.toString(),
            'title': title,
            'lat': lat.toString(),
            'lon': lon.toString(),
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

        print('Update response status: ${response.statusCode}');
        print('Update response data: ${response.data}');

        return response.statusCode == 200;
      }
    } catch (e) {
      print('Error updating landmark: $e');
      if (e is DioException) {
        print('DioError response: ${e.response?.data}');
      }
      return false;
    }
  }

  /// Delete a landmark
  Future<bool> deleteLandmark(int id) async {
    try {
      final dio = _getDio();

      final response = await dio.delete(
        '',
        queryParameters: {
          'id': id.toString(),
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response data: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting landmark: $e');
      if (e is DioException) {
        print('DioError response: ${e.response?.data}');
      }
      return false;
    }
  }
}