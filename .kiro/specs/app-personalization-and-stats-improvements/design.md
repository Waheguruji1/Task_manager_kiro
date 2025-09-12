# Design Document

## Overview

This design outlines the technical approach for improving app personalization and statistics visualization. The solution focuses on fixing username display issues, replacing the problematic heatmap with a clean bar chart, implementing automatic data management for current year only, and enhancing notification debugging through snackbar feedback.

## Architecture

### Component Structure
```
lib/
├── widgets/
│   ├── monthly_bar_chart.dart          # New bar chart widget
│   └── notification_debug_snackbar.dart # New snackbar debugging system
├── services/
│   ├── yearly_data_cleanup_service.dart # New service for year-based cleanup
│   └── notification_service.dart        # Enhanced with snackbar debugging
├── screens/
│   ├── home_screen.dart                 # Fixed username display
│   ├── stats_screen.dart                # Updated with bar chart
│   └── achievements_screen.dart         # Enhanced auto-refresh
└── providers/
    └── providers.dart                   # Enhanced refresh mechanisms
```

### Data Flow
1. **Username Flow**: Welcome Screen → PreferencesService → UserStateNotifier → HomeScreen
2. **Stats Flow**: TaskStateNotifier → StatsService → MonthlyBarChart → UI
3. **Cleanup Flow**: App Startup → YearlyDataCleanupService → DatabaseService
4. **Notification Flow**: NotificationService → SnackbarDebugger → UI Feedback

## Components and Interfaces

### MonthlyBarChart Widget
```dart
class MonthlyBarChart extends StatefulWidget {
  final List<Task> tasks;
  final int selectedMonth;
  final Function(int) onMonthChanged;
  
  // Methods:
  // - _calculateMonthlyData(): Map<int, int>
  // - _getMaxValue(Map<int, int>): int
  // - _getBarColor(int, int): Color
  // - _buildBar(int, int, int): Widget
}
```

### YearlyDataCleanupService
```dart
class YearlyDataCleanupService {
  // Methods:
  // - cleanupPreviousYearData(): Future<bool>
  // - shouldPerformCleanup(): Future<bool>
  // - getDataRetentionCutoff(): DateTime
  // - cleanupAchievementData(): Future<void>
  // - cleanupStatsData(): Future<void>
}
```

### NotificationDebugSnackbar
```dart
class NotificationDebugSnackbar {
  // Methods:
  // - showSuccess(BuildContext, String): void
  // - showError(BuildContext, String): void
  // - showWarning(BuildContext, String): void
  // - showInfo(BuildContext, String): void
}
```

### Enhanced Providers
```dart
// Auto-refresh providers for stats and achievements
final autoRefreshStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>();
final autoRefreshAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>();
```

## Data Models

### Monthly Statistics Data
```dart
class MonthlyStatsData {
  final int month;
  final int year;
  final int completedTasks;
  final int totalTasks;
  final double completionRate;
  
  MonthlyStatsData({
    required this.month,
    required this.year,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionRate,
  });
}
```

### Cleanup Configuration
```dart
class DataCleanupConfig {
  final int retentionYears;
  final bool preserveTaskData;
  final bool cleanupAchievements;
  final bool cleanupStats;
  
  static const DataCleanupConfig currentYearOnly = DataCleanupConfig(
    retentionYears: 1,
    preserveTaskData: true,
    cleanupAchievements: true,
    cleanupStats: true,
  );
}
```

## Error Handling

### Username Display Fallbacks
1. **Primary**: Display actual username from preferences
2. **Fallback 1**: Display "there" if username is empty
3. **Fallback 2**: Display "there" if preferences service fails
4. **Error State**: Show loading state during async operations

### Data Cleanup Error Handling
1. **Silent Failures**: Log errors but don't interrupt app startup
2. **Retry Logic**: Attempt cleanup on next app launch if failed
3. **Partial Success**: Continue with partial cleanup if some operations fail
4. **User Notification**: Only notify user of critical failures via snackbar

### Notification Debugging Strategy
1. **Replace Print Statements**: Convert all debugPrint to snackbar messages
2. **Contextual Messages**: Show specific error details and suggested actions
3. **Success Feedback**: Confirm successful operations with brief snackbars
4. **Error Categories**: Different snackbar styles for errors, warnings, info

## Testing Strategy

### Unit Tests
- `MonthlyBarChart` widget rendering and interaction
- `YearlyDataCleanupService` data filtering and cleanup logic
- Username display logic in `HomeScreen`
- Notification snackbar message formatting

### Integration Tests
- End-to-end username flow from welcome to home screen
- Stats screen navigation and auto-refresh behavior
- Achievement screen navigation and data updates
- Data cleanup service integration with database

### Widget Tests
- Bar chart month selection and highlighting
- Snackbar display and dismissal
- Stats screen layout with new bar chart
- Achievement screen refresh indicators

## Performance Considerations

### Data Cleanup Optimization
- **Background Processing**: Run cleanup during app initialization
- **Batch Operations**: Group database operations for efficiency
- **Incremental Cleanup**: Only process data that needs cleaning
- **Memory Management**: Dispose of large data sets after processing

### UI Responsiveness
- **Async Loading**: Use FutureBuilder for data-dependent widgets
- **Smooth Animations**: Implement proper animation curves for bar chart
- **Lazy Loading**: Load stats data only when stats screen is accessed
- **Provider Optimization**: Use autoDispose for temporary data providers

### Caching Strategy
- **Username Caching**: Cache username in memory after first load
- **Stats Caching**: Cache monthly data until task state changes
- **Achievement Caching**: Cache achievement progress between updates
- **Cleanup State**: Remember last cleanup date to avoid redundant operations

## Security Considerations

### Data Privacy
- **Local Storage Only**: All data remains on device
- **Secure Cleanup**: Ensure deleted data is properly removed
- **Username Protection**: Store username securely in encrypted preferences
- **Debug Information**: Avoid exposing sensitive data in snackbar messages

### Error Information Disclosure
- **Generic Messages**: Show user-friendly messages instead of technical details
- **Logging Separation**: Keep detailed logs separate from user-visible messages
- **Context Filtering**: Remove sensitive context from error messages
- **Debug Mode**: Enhanced debugging only in development builds