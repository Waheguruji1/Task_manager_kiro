# Technology Stack

## Framework & Platform
- **Flutter**: Cross-platform mobile app framework (SDK ^3.0.0)
- **Dart**: Programming language
- **Target Platforms**: Android, iOS, Linux, macOS, Windows, Web

## State Management
- **flutter_riverpod**: Reactive state management with compile-time safety
- Provider-based architecture for dependency injection and state handling

## Database & Storage
- **Drift**: Type-safe SQL database layer with code generation (^2.14.1)
- **sqlite3_flutter_libs**: SQLite3 native libraries for cross-platform support
- **shared_preferences**: Key-value storage for user preferences and settings
- **path_provider**: File system access for database storage location

## UI & Design
- **Custom Font**: Sour Gummy font family for unique typography
- **Material Design 3**: Using Material 3 design system with dark theme
- **Custom Theme**: Comprehensive dark theme with grey/black/white color scheme

## Features & Services
- **flutter_local_notifications**: Local push notifications for task reminders
- **timezone**: Timezone support for notification scheduling
- **share_plus**: Cross-platform sharing functionality
- **intl**: Internationalization and date formatting utilities

## Development Tools
- **drift_dev**: Code generation for database operations (^2.14.1)
- **build_runner**: Build system for code generation (^2.4.7)
- **flutter_lints**: Recommended linting rules for code quality

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Generate database code (run after modifying database schema)
dart run build_runner build

# Watch for changes and regenerate code automatically
dart run build_runner watch

# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>
```

### Code Generation
```bash
# Clean previous builds and regenerate
dart run build_runner build --delete-conflicting-outputs

# Generate code for specific directories
dart run build_runner build --build-filter="lib/models/**"
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build app bundle for Android
flutter build appbundle

# Build for iOS
flutter build ios

# Build for web
flutter build web
```

### Database Management
```bash
# After modifying lib/models/database.dart, always run:
dart run build_runner build

# This generates the database.g.dart file with table definitions
```

## Architecture Patterns
- **Simple Component-Based**: Avoids complex patterns like MVVM for maintainability
- **Service Layer**: Separate services for database, preferences, notifications, etc.
- **Provider Pattern**: Using Riverpod for dependency injection and state management
- **Repository Pattern**: DatabaseService acts as repository for data operations