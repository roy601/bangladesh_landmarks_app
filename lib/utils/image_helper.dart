import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'constants.dart';

class ImageHelper {
  /// Resize image to specified dimensions
  static Future<File> resizeImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      // Resize image to 800x600
      img.Image resized = img.copyResize(
        image,
        width: AppConstants.imageWidth,
        height: AppConstants.imageHeight,
      );

      // Encode to JPEG
      final resizedBytes = img.encodeJpg(
        resized,
        quality: AppConstants.imageQuality,
      );

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final resizedFile = File('${tempDir.path}/resized_$timestamp.jpg');
      await resizedFile.writeAsBytes(resizedBytes);

      return resizedFile;
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  static Future<bool> isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
}
