# GuardTrack

**Secure Arrival. Verified Presence.**

GuardTrack is a comprehensive Flutter mobile application designed for security guard attendance tracking with GPS verification and geofencing capabilities.

## Features

### 🔐 Authentication & Security
- Secure login with email/phone and password
- JWT token-based authentication
- Role-based access control (Guard, Admin, Super Admin)
- Secure token storage using Flutter Secure Storage

### 📍 Location & GPS Tracking
- Real-time GPS location tracking
- Geofencing for site-based check-ins
- Location accuracy validation
- Offline location caching

### ✅ Attendance Management
- GPS-verified check-in/check-out
- Unique arrival code generation
- Photo verification support
- Attendance history with filtering
- Real-time status updates

### 🏢 Site Management
- Assigned site viewing
- Site details with interactive maps
- Distance calculation and validation
- Geofence radius visualization

### 📱 User Experience
- Beautiful, intuitive UI design
- Offline-first architecture
- Real-time sync when online
- Comprehensive error handling
- Loading states and animations

## Technical Architecture

### 🏗️ Architecture Pattern
- **Clean Architecture** with clear separation of concerns
- **BLoC Pattern** for state management
- **Repository Pattern** for data access
- **Service Layer** for business logic

### 📦 Key Dependencies
- **flutter_bloc**: State management
- **geolocator**: GPS and location services
- **camera**: Photo capture functionality
- **dio**: HTTP client for API calls
- **flutter_secure_storage**: Secure data storage
- **sqflite**: Local database
- **connectivity_plus**: Network connectivity
- **firebase_messaging**: Push notifications
- **json_annotation**: JSON serialization

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd guardtrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Build & Deployment

### Android
```bash
# Build APK
flutter build apk --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release
```

---

**GuardTrack** - Making security attendance tracking simple, secure, and reliable.
