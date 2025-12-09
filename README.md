# Bangladesh Landmarks App

A Flutter mobile application for managing and visualizing landmarks in Bangladesh with REST API integration, offline caching, and interactive map features.

## Features

Interactive Map View - OpenStreetMap with custom markers  
List View - Scrollable cards with swipe-to-edit/delete  
Add/Edit Landmarks - Form with GPS auto-detection  
Image Management - Camera/gallery picker with auto-resize to 800x600  
REST API Integration - Full CRUD operations (GET, POST, PUT, DELETE)  
Error Handling - User-friendly messages and confirmations

# Bonus Features
Offline Caching - SQLite database for viewing landmarks without internet  
Map Location Picker - Tap on map to select coordinates  
Search - Filter landmarks by title  
Pull-to-Refresh - Sync with server

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



## Known Limitations

- GPS may not work properly in Android emulator
- Image uploads limited by server constraints
- Delete operation requires active internet connection

