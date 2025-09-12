# Implementation Plan

## Task Overview

Convert the app personalization and stats improvements design into a series of coding tasks that implement username fixes, bar chart visualization, data management, and notification debugging. Each task builds incrementally and focuses on specific coding objectives with clear requirements references.

## Implementation Tasks

- [x] 1. Fix username personalization display system
  - Update home screen greeting logic to properly display actual username
  - Fix userNameProvider to ensure consistent username retrieval
  - Implement proper fallback handling for missing or empty usernames
  - Test username display across different app states and error conditions
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Create monthly bar chart widget for stats visualization
  - Implement MonthlyBarChart widget with vertical bars for monthly completion data
  - Add month selection functionality with visual highlighting
  - Create responsive bar height calculation based on completion counts
  - Implement smooth animations for bar interactions and month changes
  - Add proper color coding for different completion levels
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 3. Implement yearly data cleanup service
  - Create YearlyDataCleanupService for automatic previous year data removal
  - Implement background cleanup that preserves task data but removes stats/info data
  - Add logic to detect year transitions and trigger fresh data start
  - Ensure cleanup runs silently on app startup without user prompts
  - Create data retention policies that keep only current year statistics
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Update stats screen to use bar chart instead of heatmap
  - Remove existing heatmap widget and month selector components completely
  - Integrate new MonthlyBarChart widget into stats screen layout
  - Update stats screen to filter and display only current year data
  - Implement proper error handling and loading states for bar chart
  - Ensure responsive design works across different screen sizes
  - _Requirements: 2.1, 2.2, 3.2, 4.1, 4.2_

- [ ] 5. Create current year only month selector
  - Implement month selector that shows only current year months
  - Add month name display (Jan, Feb, etc.) without date selection
  - Set default selection to current month on component load
  - Create proper month change handling that updates visualization
  - Ensure month selector integrates seamlessly with bar chart
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 6. Implement auto-refresh system for stats and achievements
  - Update providers to automatically refresh when navigating to stats screen
  - Implement achievement progress auto-refresh on achievements screen navigation
  - Create task change detection that triggers immediate UI updates
  - Add seamless refresh mechanism that doesn't show loading delays
  - Ensure data modifications reflect immediately in stats and achievements
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 7. Replace notification print statements with snackbar system
  - Create NotificationDebugSnackbar utility for user-visible debugging
  - Replace all debugPrint statements in notification service with snackbar calls
  - Implement different snackbar styles for errors, warnings, success, and info
  - Add clear error messages with actionable guidance for notification issues
  - Create success feedback snackbars for successful notification operations
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Update providers for enhanced data management
  - Modify existing providers to support auto-refresh functionality
  - Add provider invalidation logic for stats and achievements screens
  - Implement proper provider disposal and memory management
  - Create provider observers for debugging state changes
  - Ensure providers work efficiently with new yearly data cleanup
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 9. Integrate yearly cleanup with app initialization
  - Add yearly data cleanup service to app startup sequence
  - Implement cleanup trigger detection based on stored last cleanup date
  - Ensure cleanup service works with existing database service
  - Add error handling for cleanup failures that don't break app startup

  - _Requirements: 3.1, 3.4, 3.5_

- [ ] 10. Test and validate all personalization improvements
  - Test username display consistency across all app screens
  - Validate bar chart functionality with various data scenarios
  - Test auto-refresh behavior when navigating between screens
  - Verify notification snackbar system works for all notification operations
  - Test yearly data cleanup with simulated year transitions
  - Ensure all components work together seamlessly
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 5.1, 6.1_