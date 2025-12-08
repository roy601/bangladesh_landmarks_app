class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // Map Configuration
  static const double bangladeshLat = 23.6850;
  static const double bangladeshLon = 90.3563;
  static const double defaultZoom = 7.0;

  // Image Configuration
  static const int imageWidth = 800;
  static const int imageHeight = 600;
  static const int imageQuality = 85;

  // UI Constants
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String noLocationPermission = 'Location permission denied';
  static const String noCameraPermission = 'Camera permission denied';

  // Success Messages
  static const String addSuccess = 'Landmark added successfully!';
  static const String updateSuccess = 'Landmark updated successfully!';
  static const String deleteSuccess = 'Landmark deleted successfully!';
  // Authentication Messages (NEW)
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully!';
  static const String loginError = 'Invalid email or password';
  static const String registerError = 'Registration failed. Please try again.';
  static const String authRequired = 'Please login to continue';
}
