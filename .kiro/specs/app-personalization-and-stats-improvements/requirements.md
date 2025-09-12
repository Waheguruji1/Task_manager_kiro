# Requirements Document

## Introduction

This feature focuses on improving the app's personalization and statistics visualization system. The current app has several issues: username display problems, a non-functional heatmap widget, inefficient data management, and poor notification debugging. This enhancement will create a more personalized user experience with better data visualization and improved system reliability.

## Requirements

### Requirement 1: Username Personalization Fix

**User Story:** As a user, I want to see my actual username displayed consistently throughout the app, so that I feel the app is personalized for me.

#### Acceptance Criteria

1. WHEN the user enters their username on the welcome screen THEN the username SHALL be stored properly in preferences
2. WHEN the user navigates to the home screen THEN the greeting SHALL display their actual username instead of "Hello there"
3. WHEN the username is displayed anywhere in the app THEN it SHALL show the user's actual name instead of generic "user" text
4. IF no username is available THEN the app SHALL fallback to "there" as a default greeting

### Requirement 2: Replace Heatmap with Bar Chart Visualization

**User Story:** As a user, I want to see my task completion data in a clear bar chart format, so that I can easily understand my productivity patterns.

#### Acceptance Criteria

1. WHEN the user navigates to the stats screen THEN the old heatmap widget SHALL be completely removed
2. WHEN the stats screen loads THEN a new bar chart widget SHALL display monthly task completion data
3. WHEN viewing the bar chart THEN it SHALL show vertical bars representing completed tasks for each month
4. WHEN the user taps on a month bar THEN that month SHALL be highlighted and show detailed information
5. WHEN displaying the chart THEN it SHALL only show data for the current year
6. WHEN no data exists for a month THEN the bar SHALL show as minimal height with appropriate visual indication

### Requirement 3: Current Year Only Data Management

**User Story:** As a user, I want the app to automatically manage my data to show only current year statistics, so that the interface remains clean and relevant.

#### Acceptance Criteria

1. WHEN the app starts THEN it SHALL automatically remove previous year's statistics data in the background
2. WHEN displaying stats THEN the app SHALL show only current year data
3. WHEN a new year begins THEN the app SHALL start fresh with new year data
4. WHEN cleaning old data THEN task data SHALL be preserved but statistics/info data SHALL be removed
5. WHEN data cleanup occurs THEN it SHALL happen silently without user prompts

### Requirement 4: Month Selector for Current Year Only

**User Story:** As a user, I want to select months from the current year only, so that I can focus on relevant recent data.

#### Acceptance Criteria

1. WHEN the month selector is displayed THEN it SHALL show only months from the current year
2. WHEN the user selects a month THEN the visualization SHALL update to highlight that month's data
3. WHEN the month selector loads THEN it SHALL default to the current month
4. WHEN displaying months THEN it SHALL show month names (Jan, Feb, etc.) without date selection

### Requirement 5: Auto-refresh Stats and Achievements

**User Story:** As a user, I want the stats and achievements to automatically update when I navigate to those sections, so that I always see current information.

#### Acceptance Criteria

1. WHEN the user navigates to the stats screen THEN all statistics SHALL automatically refresh
2. WHEN the user navigates to the achievements screen THEN achievement progress SHALL automatically update
3. WHEN the user completes or modifies tasks THEN stats and achievements SHALL reflect changes immediately
4. WHEN data modifications occur THEN the UI SHALL update without requiring manual refresh
5. WHEN navigation occurs THEN the refresh SHALL happen seamlessly without loading delays

### Requirement 6: Notification Debugging with Snackbars

**User Story:** As a developer/user, I want to see notification issues through snackbar messages instead of print statements, so that I can identify and resolve notification problems.

#### Acceptance Criteria

1. WHEN notification operations occur THEN debug information SHALL be displayed via snackbars instead of print statements
2. WHEN notification scheduling fails THEN a clear error message SHALL appear in a snackbar
3. WHEN notification permissions are missing THEN the user SHALL be informed via snackbar with actionable guidance
4. WHEN notification operations succeed THEN success feedback SHALL be shown via snackbar
5. WHEN debugging is active THEN snackbar messages SHALL be clear and informative for troubleshooting