# Project Structure

## Directory Organization

```
lib/
├── main.dart                    # App entry point with theme and navigation setup
├── models/                      # Data models and database schema
│   ├── achievement.dart         # Achievement data model with progress tracking
│   ├── database.dart           # Drift database schema and table definitions
│   ├── database.g.dart         # Generated database code (auto-generated)
│   ├── task.dart               # Task model with priority and notification support
│   └── user.dart               # User data model
├── providers/                   # Riverpod state management
│   ├── provider_observer.dart   # Debug observer for provider state changes
│   ├── providers.dart          # All provider definitions and dependencies
│   ├── task_state_notifier.dart # Task state management and operations
│   └── user_state_notifier.dart # User authentication and profile state
├── screens/                     # Full-screen UI components
│   ├── home_screen.dart        # Main task management with tabs
│   ├── main_navigation_screen.dart # Bottom navigation wrapper
│   ├── settings_screen.dart    # App settings and preferences
│   ├── stats_screen.dart       # Analytics, heatmaps, and achievements
│   └── welcome_screen.dart     # User onboarding and name input
├── services/                    # Business logic and external integrations
│   ├── achievement_service.dart # Achievement tracking and progress calculation
│   ├── database_service.dart   # Database operations and query abstraction
│   ├── notification_service.dart # Local notification scheduling and management
│   ├── preferences_service.dart # SharedPreferences wrapper for user settings
│   ├── share_service.dart      # App sharing functionality
│   └── stats_service.dart      # Statistics calculation and heatmap data
├── utils/                       # Utilities and configuration
│   ├── constants.dart          # App constants and string literals
│   ├── error_handler.dart      # Centralized error handling and logging
│   ├── responsive.dart         # Responsive design utilities
│   ├── theme.dart              # Comprehensive dark theme configuration
│   └── validation.dart         # Input validation utilities
└── widgets/                     # Reusable UI components
    ├── achievement_example.dart # Example achievement widget usage
    ├── achievement_widget.dart  # Individual achievement display with progress
    ├── add_task_dialog.dart    # Task creation and editing dialog
    ├── app_icon.dart           # Animated app icon component
    ├── compact_task_widget.dart # Condensed task display for lists
    ├── custom_app_bar.dart     # Themed app bar with share functionality
    ├── custom_text_field.dart  # Themed input field with validation
    ├── error_boundary.dart     # Error boundary widget for crash handling
    ├── heatmap_example.dart    # Example heatmap widget usage
    ├── heatmap_widget.dart     # Calendar-style heatmap visualization
    ├── task_container.dart     # Daily task container with date header
    └── task_item.dart          # Individual task with checkbox and actions
```

## Key Architectural Principles

### File Naming Conventions
- **snake_case**: All file and directory names use snake_case
- **Descriptive Names**: Files clearly indicate their purpose (e.g., `task_state_notifier.dart`)
- **Screen Suffix**: Screen files end with `_screen.dart`
- **Service Suffix**: Service files end with `_service.dart`
- **Widget Suffix**: Reusable widgets end with `_widget.dart` or descriptive names

### Code Organization Rules

#### Models (`lib/models/`)
- Pure data classes with serialization methods
- Database schema definitions using Drift annotations
- Immutable objects with `copyWith()` methods
- Business logic helpers (e.g., priority colors, sorting)

#### Providers (`lib/providers/`)
- All Riverpod providers centralized in `providers.dart`
- StateNotifiers for complex state management
- Async providers for service initialization
- Provider observer for debugging state changes

#### Screens (`lib/screens/`)
- Full-screen UI components
- ConsumerWidget or ConsumerStatefulWidget for Riverpod integration
- Screen-specific state management
- Navigation logic contained within screens

#### Services (`lib/services/`)
- Business logic abstraction
- External API integrations
- Database operation wrappers
- Singleton pattern for stateful services

#### Widgets (`lib/widgets/`)
- Reusable UI components
- Stateless when possible
- Clear prop interfaces with required parameters
- Theme-consistent styling

#### Utils (`lib/utils/`)
- Pure utility functions
- Configuration objects
- Constants and enums
- Helper methods without side effects

### Import Organization
```dart
// 1. Flutter/Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. Third-party package imports
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 3. Local imports (relative paths)
import '../models/task.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
```

### State Management Patterns
- **Providers**: For dependency injection and simple state
- **StateNotifiers**: For complex state with multiple operations
- **FutureProviders**: For async initialization and data fetching
- **StreamProviders**: For real-time data updates (if needed)

### Error Handling Strategy
- Centralized error handling in `utils/error_handler.dart`
- Service-level error catching and transformation
- UI-level error boundaries for crash prevention
- User-friendly error messages with recovery options

### Testing Structure
```
test/
├── models/                      # Model unit tests
├── services/                    # Service unit tests
├── widgets/                     # Widget tests
├── screens/                     # Screen integration tests
└── integration/                 # Full app integration tests
```

### Asset Organization
```
assets/
├── fonts/
│   └── SourGummy-Regular.ttf   # Custom font file
└── icons/
    └── app_icon.svg            # App icon in SVG format
```

### Configuration Files
- `pubspec.yaml`: Dependencies, assets, and app metadata
- `analysis_options.yaml`: Dart linting rules and analysis options
- `.gitignore`: Version control exclusions
- Platform-specific configs in `android/`, `ios/`, etc.

## Development Workflow

### Adding New Features
1. Create model in `lib/models/` if needed
2. Add service methods in appropriate `lib/services/` file
3. Create or update providers in `lib/providers/providers.dart`
4. Build UI components in `lib/widgets/`
5. Integrate in appropriate screen in `lib/screens/`
6. Add tests in corresponding `test/` directories

### Database Changes
1. Modify schema in `lib/models/database.dart`
2. Run `dart run build_runner build` to generate code
3. Update service methods in `lib/services/database_service.dart`
4. Test migration and data integrity

### Theme Updates
1. Modify `lib/utils/theme.dart`
2. Update component styling to use theme values
3. Test across all screens for consistency
4. Verify accessibility compliance