# Bangladesh Landmarks App

A Flutter mobile application for managing and visualizing landmarks in Bangladesh with REST API integration, offline caching, and interactive map features.

## Features

Interactive Map View - OpenStreetMap with custom markers  
List View - Scrollable cards with swipe-to-edit/delete  
Add/Edit Landmarks - Form with GPS auto-detection  
Image Management - Camera/gallery picker with auto-resize to 800x600  
REST API Integration - Full CRUD operations (GET, POST, PUT, DELETE)  
Error Handling - User-friendly messages and confirmations

### Bonus Features
Offline Caching - SQLite database for viewing landmarks without internet  
Map Location Picker - Tap on map to select coordinates  
Search - Filter landmarks by title  
Pull-to-Refresh - Sync with server

## Screenshots

[Add your screenshots here after taking them]

## Tech Stack

Framework: Flutter 3.0+
State Management: Provider
Maps: OpenStreetMap (flutter_map)
API Client: Dio
Local Database: SQLite (sqflite)
Image Processing: image package
Location: Geolocator

## Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / VS Code
- Android Emulator or Physical Device
- Internet connection for API calls

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/roy601/bangladesh_landmarks_app
cd bangladesh_landmarks_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
# For Android emulator
flutter run

# For specific device
flutter run 

# Check available devices
flutter devices
```

## API Configuration

**Base URL:** `https://labs.anontech.info/cse489/t3/api.php`

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | /api.php | Fetch all landmarks |
| POST   | /api.php | Create new landmark |
| PUT    | /api.php | Update landmark |
| DELETE | /api.php | Delete landmark |

## Project Structure
```
lib/
├── config/          # Theme and app configuration
├── models/          # Data models (Landmark)
├── providers/       # State management (Provider)
├── screens/         # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── map_view_screen.dart
│   ├── list_view_screen.dart
│   ├── form_screen.dart
│   └── map_picker_screen.dart
├── services/        # Business logic
│   ├── api_service.dart
│   ├── database_service.dart
│   └── location_service.dart
├── utils/           # Helper functions
│   ├── constants.dart
│   └── image_helper.dart
├── widgets/         # Reusable components
└── main.dart        # App entry point
```

## Features in Detail

### 1. Map View
- Centered on Bangladesh (23.6850°N, 90.3563°E)
- Custom red markers for each landmark
- Tap marker to open bottom sheet with details
- "My Location" button to center on current GPS
- "Center on Bangladesh" button

### 2. List View
- Card-style items with image, title, and coordinates
- Swipe left/right for edit/delete actions
- Search bar to filter landmarks
- Pull-to-refresh to sync with API
- Empty state when no landmarks exist

### 3. Add/Edit Form
- Title input with validation
- Latitude/Longitude inputs with validation
- "Pick Location from Map" button
- Image picker (camera or gallery)
- Automatic image resize to 800x600
- GPS auto-detection button

### 4. Offline Mode (BONUS)
- Automatic caching to SQLite when online
- View cached landmarks when offline
- Orange banner indicates offline mode
- Sync automatically when back online

## Permissions Required

### Android
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

## Building for Release

### Android APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```

## Troubleshooting

### Location not working in emulator
- Use physical device for GPS testing
- Or manually set coordinates in emulator settings

### Images not uploading
- Check internet connection
- Verify image file size (< 5MB recommended)
- Ensure camera/storage permissions granted

### Offline mode not working
- First launch requires internet to fetch data
- Data is cached after first successful fetch
- Clear app data to reset cache

## Known Limitations

- GPS may not work properly in Android emulator
- Image uploads limited by server constraints
- Delete operation requires active internet connection

## Dependencies

Key packages used:
```yaml
dependencies:
  flutter_map: ^6.1.0          # OpenStreetMap
  provider: ^6.1.1             # State management
  dio: ^5.4.0                  # HTTP client
  sqflite: ^2.3.0              # Local database
  geolocator: ^10.1.0          # GPS location
  image_picker: ^1.0.5         # Camera/Gallery
  image: ^4.1.3                # Image processing
  cached_network_image: ^3.3.0 # Image caching
  flutter_slidable: ^3.0.1     # Swipe gestures
```

## Development

### Run with hot reload
```bash
flutter run
```

Press `r` to hot reload  
Press `R` to hot restart  
Press `q` to quit

### Format code
```bash
dart format lib/
```

### Analyze code
```bash
flutter analyze
```

## Contributing

This is an academic project for CSE 489 - Mobile Application Development.

## Author

**[Your Name]**  
Student ID: [Your ID]  
BRAC University  
Course: CSE 489 - Mobile Application Development

## License

This project is created for educational purposes.

## Acknowledgments

- OpenStreetMap for map tiles
- BRAC University CSE Department
- Course Instructor: [Instructor Name]