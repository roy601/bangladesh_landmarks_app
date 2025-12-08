# Bangladesh Landmarks App

A Flutter mobile application for managing and visualizing landmarks in Bangladesh with REST API integration, offline caching, and real-time GPS location.

## Features

**Map View** - Interactive Google Maps showing all landmarks  
**List View** - Scrollable list with swipe-to-edit/delete  
**Add/Edit Form** - Create and update landmarks with images  
**GPS Integration** - Auto-detect current location  
**Image Handling** - Automatic resize to 800x600  
**Offline Caching** - View landmarks without internet (BONUS)  
**REST API** - Full CRUD operations

## Tech Stack

- **Framework:** Flutter 3.0+
- **State Management:** Provider
- **Database:** SQLite (sqflite) for offline caching
- **Maps:** OpenStreetMap
- **API:** REST API with Dio
- **Image Processing:** Image package

## Screenshots

[Add your screenshots here]

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository:**
```bash
   git clone <your-repo-url>
   cd bangladesh_landmarks_app
```

2. **Install dependencies:**
```bash
   flutter pub get
```

3. **Configure Google Maps API Key:**
    - Get API key from Google Cloud Console
    - Add to `android/app/src/main/AndroidManifest.xml`
```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
```

4. **Run the app:**
```bash
   flutter run
```

## API Details

**Base URL:** `https://labs.anontech.info/cse489/t3/api.php`

**Endpoints:**
- `GET /` - Fetch all landmarks
- `POST /` - Create new landmark
- `PUT /` - Update existing landmark
- `DELETE /` - Delete landmark

## Project Structure
```
lib/
├── config/          # App configuration (theme)
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # API, database, location services
├── utils/           # Helper functions & constants
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## Key Features Implemented

### 1. Bottom Navigation
- Map View tab
- List View tab
- Add New Entry tab

### 2. Map Integration
- Centered on Bangladesh (23.6850°N, 90.3563°E)
- Custom markers for each landmark
- Bottom sheet on marker tap
- Current location button

### 3. List View
- RecyclerView with cards
- Swipe gestures for edit/delete
- Search functionality
- Pull-to-refresh

### 4. Form Management
- Add new landmarks
- Edit existing landmarks
- Image picker (camera/gallery)
- Auto-resize images to 800x600
- GPS auto-detection
- Form validation

### 5. Offline Caching (BONUS)
- SQLite local database
- Automatic sync when online
- View cached data offline

## Challenges & Solutions

### Challenge 1: Image Resizing
**Problem:** Large images causing slow uploads  
**Solution:** Implemented automatic resize to 800x600 using `image` package

### Challenge 2: Offline Mode
**Problem:** App crashes without internet  
**Solution:** Implemented SQLite caching with fallback mechanism

### Challenge 3: Location Permissions
**Problem:** Runtime permission handling  
**Solution:** Used `permission_handler` with proper error handling

## Author

**Your Name**  
Student ID: [Your ID]  
Course: CSE 489 - Mobile Application Development
