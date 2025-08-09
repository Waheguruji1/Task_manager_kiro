# Task Manager App: An Encyclopedia

## Introduction

This document provides a deeply detailed, file-by-file breakdown of the Task Manager application's codebase. It is intended to be an "encyclopedia" for developers, offering a granular look at every component, from data models to UI widgets.

The guide is structured to mirror the project's file organization. Each section corresponds to a directory within the `lib/` folder, and each subsection covers a specific file, detailing its purpose, classes, methods, and functions.

This approach is designed to give developers, regardless of their experience level, a precise and comprehensive understanding of how every part of the application works.

## 1. `lib/utils/`

This directory contains utility files that provide shared, reusable logic and values throughout the application.

### 1.1. `lib/utils/constants.dart`

This file is a central repository for all constant values and string literals used in the app. Centralizing these values prevents magic strings/numbers in the codebase and makes it easy to update them globally.

#### `AppConstants` class

This class holds general application-level constants.

-   **Purpose:** To define non-UI, configuration-related constants.
-   **Key Constants:**
    -   `appName`: The official name of the application ("Task Manager").
    -   `appVersion`: The current version of the app.
    -   `userNameKey`, `lastResetDateKey`, etc.: Keys used for storing data in `SharedPreferences`.
    -   `databaseName`, `databaseVersion`: Configuration for the `drift` database.
    -   `maxTaskTitleLength`, `maxUserNameLength`: Constraints for user input length.
    -   `shortAnimationDuration`, etc.: Standard durations for animations.

#### `AppRoutes` class

This class defines the named routes used for navigation.

-   **Purpose:** To provide a single source of truth for navigation route names, preventing typos.
-   **Key Routes:**
    -   `/welcome`: The route for the `WelcomeScreen`.
    -   `/main`: The route for the `MainNavigationScreen`.

#### `AppStrings` class

This class contains all user-facing string literals.

-   **Purpose:** To centralize all text shown in the UI. This is crucial for consistency and would be essential for future internationalization efforts.
-   **Content:** It includes strings for greetings, button labels, error messages, validation messages, accessibility labels, and more.

#### `AppIcons` class

This class defines string constants for icon assets (though the app primarily uses `IconData` from Material/Cupertino).

-   **Purpose:** To provide a consistent way to reference icon assets if they were being used as strings.

#### `AppAssets` class

This class defines the file paths for all static assets.

-   **Purpose:** To provide a single, reliable source for asset paths, preventing errors from typos in file paths.
-   **Key Assets:**
    -   `sourGummyFont`: The path to the custom font file.
    -   `appLogo`, `emptyState`: Paths for image assets.

### 1.2. `lib/utils/error_handler.dart`

This file provides a centralized system for error handling, logging, and displaying common UI states (loading, error, empty).

#### `ErrorType` enum

An enum to categorize different types of errors that can occur in the app, such as `database`, `validation`, or `unknown`.

#### `AppException` class

A custom exception class used to wrap errors that occur within the application.

-   **Purpose:** To provide more context about an error than a standard `Exception`. It includes a user-friendly `message`, an `ErrorType`, the `originalError`, and an optional `stackTrace`.

#### `ErrorHandler` class

A utility class with static methods to handle errors and logging consistently.

-   **`logError(...)`**: A static method for logging errors. In `kDebugMode` (debug builds), it prints the formatted error and stack trace to the console. In release builds, this is where you would hook in a crash reporting service like Firebase Crashlytics or Sentry.
-   **`logInfo(...)`**: A static method for logging informational messages, useful for debugging and monitoring application flow.
-   **`handle...Error(...)` methods**: A suite of methods (`handleDatabaseError`, `handlePreferencesError`, etc.) that take a raw error, log it using `logError`, and then return a user-friendly error message string suitable for showing in the UI.
-   **`show...SnackBar(...)` methods**: A set of static methods (`showErrorSnackBar`, `showSuccessSnackBar`, etc.) for showing consistently styled `SnackBar` widgets to the user. This is the primary way the app provides transient feedback.

#### UI State Widgets

The file also contains several reusable widgets for displaying different UI states:

-   **`ErrorDisplayWidget`**: A widget that shows a centered error message with an icon and an optional "Retry" button. It's used when a screen or a major component fails to load.
-   **`LoadingWidget`**: A widget that shows a centered `CircularProgressIndicator` with an optional loading message.
-   **`EmptyStateWidget`**: A widget used to inform the user when there is no data to display (e.g., an empty task list). It shows an icon, a title, a subtitle, and an optional action button to encourage user interaction.

### 1.3. `lib/utils/responsive.dart`

This file contains a collection of utilities and widgets to help build a responsive UI that looks good on various devices, from small phones to large desktops.

#### `ScreenSize` enum

A simple enum to represent different screen size categories: `mobile`, `tablet`, and `desktop`.

#### `ResponsiveUtils` class

A utility class with static methods to get responsive values based on the current screen context.

-   **Purpose:** To centralize the logic for calculating sizes, paddings, and other UI values that need to adapt to the screen size.
-   **Key Methods:**
    -   **`getScreenSize(context)`**: Determines the current `ScreenSize` (mobile, tablet, or desktop) based on the screen width.
    -   **`isLandscape(context)` / `isPortrait(context)`**: Checks the current device orientation.
    -   **`getScreenPadding(context)`**: Returns an `EdgeInsets` value appropriate for the current screen size and orientation.
    -   **`getFontSizeMultiplier(context)`**: Provides a multiplier to scale fonts up slightly on larger screens.
    -   **`getSpacing(context, baseSpacing)`**: Scales a base spacing value according to the screen size.
    -   **`getGridColumnCount(context)`**: Calculates the appropriate number of columns for a grid layout, considering both screen size and orientation.
    -   **`isSmallScreen(context)` / `isLargeScreen(context)`**: Helper methods to quickly check if the screen is small (mobile portrait) or large (tablet/desktop).

#### `ResponsiveBuilder` widget

A widget that rebuilds its child with information about the current screen size and orientation.

-   **Purpose:** To allow a widget to be built differently based on the responsive context without cluttering it with `MediaQuery` calls.
-   **Usage:**
    ```dart
    ResponsiveBuilder(
      builder: (context, screenSize, isLandscape) {
        if (screenSize == ScreenSize.mobile) {
          return MobileWidget();
        } else {
          return DesktopWidget();
        }
      },
    )
    ```

#### `ResponsiveLayout` widget

A layout widget that displays a different child widget based on the current screen size and orientation.

-   **Purpose:** To provide a simple way to define completely different widget trees for different responsive breakpoints.
-   **Usage:**
    ```dart
    ResponsiveLayout(
      mobile: MobileLayout(),
      tablet: TabletLayout(),
      desktop: DesktopLayout(),
    )
    ```

### 1.4. `lib/utils/theme.dart`

This file centralizes the application's visual styling. It defines a comprehensive, consistent dark theme for the entire app.

#### `AppTheme` class

A class that contains all the theme-related definitions as static members. It's not meant to be instantiated.

-   **Purpose:** To provide a single source of truth for all colors, text styles, spacing, and other UI-related constants. This ensures a consistent look and feel and makes it easy to update the app's design from one place.

-   **Static Constants:**
    -   **Color Palette:** Defines all the colors used in the app, such as `backgroundDark`, `surfaceGrey`, `primaryText`, and `purplePrimary`.
    -   **Font Family:** Specifies the `primaryFontFamily` ('Sour Gummy').
    -   **Text Styles:** Defines a set of standard `TextStyle` objects, like `headingLarge`, `bodyMedium`, etc., which are used for all text in the app.
    -   **Spacing System:** Provides a system of consistent spacing values (e.g., `spacingS`, `spacingM`, `spacingL`) used for padding and margins.
    -   **Border Radius:** Defines standard border radius values for containers, buttons, and inputs.

-   **`darkTheme` (static getter):**
    -   This getter returns a fully configured `ThemeData` object.
    -   It sets up the theme for all the core Material Design widgets, including `AppBar`, `Card`, `ElevatedButton`, `InputDecoration`, `Checkbox`, etc.
    -   This `ThemeData` object is applied to the `MaterialApp` in `main.dart`, ensuring all widgets throughout the app inherit this consistent styling.

-   **Custom Component Styles (static getters):**
    -   The class also includes static getters for custom `BoxDecoration`s, like `taskContainerDecoration` and `primaryButtonDecoration`.
    -   These are used for custom widgets that need a consistent style but aren't covered by the standard `ThemeData`.

### 1.5. `lib/utils/validation.dart`

This file provides a centralized set of utility methods for validating user input, ensuring data integrity and consistency throughout the application.

#### `ValidationUtils` class

A utility class containing static methods for various validation checks. These methods are designed to be used with `TextFormField`'s `validator` property. They return a `String` (the error message) if validation fails, and `null` if it succeeds.

-   **Purpose:** To provide a single, reusable source for all input validation logic.
-   **Key Methods:**
    -   **`validateUserName(String? value)`**: Checks if the user's name is not empty and is within the allowed length constraints.
    -   **`validateTaskTitle(String? value)`**: Checks if a task title is not empty and is within the allowed length.
    -   **`validateTaskDescription(String? value)`**: Checks if a task description does not exceed the maximum length (the description is optional).
    -   **`sanitizeInput(String input)`**: A helper method to trim whitespace and remove potentially harmful characters from user input.

#### `FormValidationHelper` class

A utility class with methods to validate entire forms at once.

-   **Purpose:** To orchestrate the validation of multiple fields in a form, such as the add/edit task dialog.
-   **Key Methods:**
    -   **`validateTaskForm(...)`**: Validates the title and description for a task, returning a `Map` of any validation errors.
    -   **`hasErrors(Map<String, String?> errors)`**: A helper to quickly check if the error map contains any validation failures.

## 2. `lib/models/`

This directory contains the data models for the application. These classes define the structure of the data that the app works with, such as tasks, users, and achievements. They are plain Dart objects that are used to represent data fetched from the database or created by the user.

### 2.1. `lib/models/achievement.dart`

This file defines the data structure for a single achievement in the app's gamification system.

#### `AchievementType` enum

An enum that defines the different categories of achievements a user can earn.

-   **Values:** `streak`, `dailyCompletion`, `weeklyCompletion`, `monthlyCompletion`, `routineConsistency`, `firstTime`.

#### `Achievement` class

A class representing a single achievement.

-   **Purpose:** To hold all the information related to an achievement, including its state (earned or not) and the user's progress towards it.
-   **Key Properties:**
    -   `id`: A unique identifier for the achievement.
    -   `title` & `description`: The user-facing text explaining the achievement.
    -   `icon`: The `IconData` to display for the achievement.
    -   `type`: The `AchievementType` of the achievement.
    -   `targetValue`: The value the user needs to reach to earn the achievement (e.g., complete 10 tasks).
    -   `currentProgress`: The user's current progress towards the `targetValue`.
    -   `isEarned`: A boolean indicating whether the user has earned the achievement.
    -   `earnedAt`: The `DateTime` when the achievement was earned.
-   **Key Methods:**
    -   **`progressPercentage` (getter):** Calculates the user's progress as a percentage (`0.0` to `1.0`), which is useful for progress bars.
    -   **`copyWith(...)`**: A standard method to create a copy of the achievement instance with some properties changed.
    -   **`toJson()` & `fromJson(...)`**: Methods for serializing the `Achievement` object to and from a JSON map. This is useful for storing achievement data, although in this project they are not directly stored in the database but are defined statically and their state is calculated.

### 2.2. `lib/models/task.dart`

This file defines the `Task` data model, which is the central data structure in the application.

#### `TaskPriority` enum

An enum that defines the different priority levels a task can have.

-   **Values:** `none`, `medium`, `high`.

#### `Task` class

The class representing a single task item. This class is used throughout the app to create, display, and manage tasks.

-   **Purpose:** To encapsulate all data related to a single task.
-   **Key Properties:**
    -   `id`: The unique ID from the database. It's nullable because a task doesn't have an ID until it's saved.
    -   `title`: The required title of the task.
    -   `description`: An optional, longer description of the task.
    -   `isCompleted`: A boolean flag indicating if the task is done.
    -   `isRoutine`: A boolean flag indicating if this is a "Routine" task template.
    -   `createdAt` & `completedAt`: Timestamps for when the task was created and completed.
    -   `routineTaskId`: For a task instance that was generated from a routine, this links back to the routine task's ID.
    -   `priority`: The `TaskPriority` of the task.
    -   `notificationId`: The ID of the scheduled local notification associated with this task.
-   **Key Methods & Getters:**
    -   **`copyWith(...)`**: A standard method for creating a modified copy of a task, which is useful for immutable state updates.
    -   **`toJson()` & `fromJson(...)`**: Methods for serialization. Although `drift` handles database mapping, these would be useful for APIs or other forms of data persistence.
    -   **`priorityColor` (getter):** Returns a specific `Color` based on the task's priority, used for UI styling.
    -   **`priorityOrder` (getter):** Returns an integer representing the priority (0 for high, 2 for none), used for sorting tasks.
    -   **`sortByPriority(List<Task> tasks)` (static method):** A static helper method to sort a list of tasks based on their priority.
    -   **`getTruncatedTitle(...)` & `getTruncatedDescription(...)`**: Helper methods to shorten long text for display in the UI, appending "..." if the text is truncated.

### 2.3. `lib/models/user.dart`

This file defines the `User` data model, which represents the application's user.

#### `User` class

A simple class to hold user-specific information.

-   **Purpose:** To store the user's name for personalization and the date they joined. In this app, there is only one user, and their information is stored in `SharedPreferences`, not in the main database.
-   **Key Properties:**
    -   `name`: The user's display name.
    -   `createdAt`: The `DateTime` when the user first set up the app.
-   **Key Methods & Getters:**
    -   **`copyWith(...)`**: A standard method for creating a modified copy of the user.
    -   **`toJson()` & `fromJson(...)`**: Methods for serializing the `User` object to and from a JSON map, used for storing the user data in `SharedPreferences`.
    -   **`greeting` (getter):** A helper that generates a time-appropriate greeting (e.g., "Good morning, [Name]!").
    -   **`daysSinceJoined` (getter):** A helper that calculates how many days it has been since the user joined.

### 2.4. `lib/models/database.dart`

This file is the heart of the application's data persistence layer. It uses the `drift` package to define the database schema, manage migrations, and provide an API for all database operations.

#### `part 'database.g.dart';`

This directive is crucial. It tells the Dart build system to include the file `database.g.dart`, which is automatically generated by `drift_dev` (via `build_runner`). This generated file contains the actual implementation of the database class (`_$AppDatabase`) and the data classes (like `TaskData`) that `drift` creates from your table definitions. **You should never edit the `.g.dart` file manually.**

#### `Tasks` table class

This class defines the schema for the `tasks` table in the SQLite database.

-   **Purpose:** To declare the columns, data types, and constraints for storing tasks.
-   **Key Columns:**
    -   `id`: The auto-incrementing primary key.
    -   `title`: A required text column.
    -   `description`: A nullable text column.
    -   `isCompleted`: A boolean column with a default value of `false`.
    -   `isRoutine`: A boolean column to flag routine task templates.
    -   `createdAt`, `completedAt`: Timestamps for tracking task lifecycle.
    -   `priority`: An integer column to store the `TaskPriority` enum index.

#### `AppDatabase` class

This is the main database class that the rest of the app interacts with.

-   **`@DriftDatabase(tables: [Tasks, Achievements])`**: This annotation tells `drift` which tables to include in the database.
-   **`extends _$AppDatabase`**: It extends the generated class from the `.g.dart` file.
-   **`schemaVersion`**: An integer that must be incremented whenever you make a change to the table schemas. This is essential for triggering migrations.
-   **`migration` strategy**: This getter defines how to handle database creation (`onCreate`) and updates (`onUpgrade`). When the schema version increases, the `onUpgrade` callback is executed, allowing you to safely add or modify tables and columns without losing user data.
-   **Query Methods:** The class contains numerous methods for performing CRUD (Create, Read, Update, Delete) operations on the tables.
    -   **`getAllTasks()`**: Fetches all tasks.
    -   **`getEverydayTasks()`**: Fetches only non-routine tasks.
    -   **`insertTask(...)`**: Inserts a new task.
    -   **`updateTask(...)`**: Updates an existing task.
    -   **`deleteTask(...)`**: Deletes a task by its ID.
    -   These methods use `drift`'s type-safe query builder, which helps prevent syntax errors and SQL injection.

#### `_openConnection()` function

A private, top-level function that sets up the connection to the SQLite database file on the device.

-   **Purpose:** It uses the `path_provider` package to find the correct directory to store the database file and then creates a `NativeDatabase` connection. Using a `LazyDatabase` ensures that the connection is only opened when it's first needed.

## 3. `lib/services/`

This directory contains the service classes for the application. A service encapsulates a specific piece of business logic or functionality, such as interacting with the database, managing user preferences, or handling notifications. This separation of concerns makes the code more modular, testable, and easier to maintain.

### 3.1. `lib/services/achievement_service.dart`

This service contains all the logic related to the app's achievement system. It is responsible for tracking user progress, calculating statistics like streaks, and determining when an achievement has been earned.

#### `AchievementService` class

This class is implemented as a singleton, meaning there is only one instance of it throughout the app's lifecycle. It depends on the `DatabaseService` to read task data and persist achievement state.

-   **Purpose:** To be the single source of truth for all achievement-related logic.
-   **Key Methods:**
    -   **`getInstance()` (static method):** The method to get the singleton instance of the service.
    -   **`getAllAchievements()`**: Fetches all achievements (both earned and unearned) from the database and calculates their current progress.
    -   **`checkAndUpdateAchievements()`**: This is the core method of the service. It should be called after any significant user action (like completing a task). It iterates through all unearned achievements, calculates the user's current progress for each one based on their task history, and updates the database if the progress has changed or if an achievement has been earned.
    -   **`_calculateCurrentStreak(...)` (private method):** A helper method that looks at the completion dates of all tasks to calculate the user's current streak of consecutive active days.
    -   **`_calculateRoutineConsistencyStreak(...)` (private method):** A helper method to calculate the streak of consecutive days where the user has completed all of their routine tasks.

### 3.2. `lib/services/database_service.dart`

This service acts as a high-level API for all database operations. It serves as a facade or a wrapper around the `AppDatabase` class, abstracting the specific `drift` implementation details from the rest of the app.

#### `DatabaseService` class

This class is implemented as a singleton to ensure that there is only one connection to the database at any given time.

-   **Purpose:** To provide a clean, simple, and centralized API for all task-related CRUD (Create, Read, Update, Delete) operations. This decouples the application logic from the database-specific code.
-   **Key Methods:**
    -   **`getInstance()` (static method):** The method to get the singleton instance of the service.
    -   **`initialize()`**: A method to initialize the database connection.
    -   **`createTask(Task task)`**: Takes a `Task` model object, converts it into a `TasksCompanion` (a `drift` object for inserts/updates), and inserts it into the database.
    -   **`getAllTasks()`**: Fetches all `TaskData` objects from the database and maps them back to a list of `Task` model objects.
    -   **`updateTask(Task task)`**: Updates an existing task in the database.
    -   **`deleteTask(int id)`**: Deletes a task by its ID.
    -   **`toggleTaskCompletion(int id)`**: A specific method to flip the `isCompleted` status of a task.
    -   **`createDailyRoutineTaskInstances()`**: Contains the logic to check which routine tasks need to be created for the current day and inserts them into the database.
-   **Error Handling:** Every method in this service is wrapped in a `try...catch` block. It uses the `ErrorHandler` utility to log any database errors and then re-throws them as a custom `AppException` with a user-friendly message. This ensures consistent error handling for all database interactions.
-   **Data Mapping:** The service includes private helper methods (`_taskDataToTask`) to map the data objects generated by `drift` (e.g., `TaskData`) to the application's own model objects (e.g., `Task`). This is a key part of decoupling the database layer from the app's business logic.

### 3.3. `lib/services/notification_service.dart`

This service encapsulates all functionality related to local notifications. It uses the `flutter_local_notifications` package to schedule and manage reminders for tasks.

#### `NotificationService` class

This class is implemented as a singleton to ensure a single point of control for notifications.

-   **Purpose:** To abstract the complexities of the `flutter_local_notifications` package and provide a simple, high-level API for notification management.
-   **Key Methods:**
    -   **`initialize()`**: Sets up the notification plugin with platform-specific settings for Android and iOS. It must be called before any other methods can be used.
    -   **`requestPermissions()`**: Prompts the user for permission to send notifications. This is required on iOS and newer versions of Android.
    -   **`scheduleTaskNotification(Task task)`**: The core method for scheduling a reminder. It takes a `Task` object, checks if it has a `notificationTime`, and if so, schedules a local notification to be delivered at that time. It returns the unique ID of the scheduled notification.
    -   **`cancelTaskNotification(int notificationId)`**: Cancels a specific notification using its ID. This is called when a task is completed or deleted.
    -   **`cancelAllNotifications()`**: Removes all scheduled notifications. This is used when the user disables notifications in the app's settings.
    -   **`rescheduleAllNotifications(List<Task> tasks)`**: A utility method that first cancels all existing notifications and then iterates through a list of tasks to schedule new reminders for them. This is useful when the app starts or when notifications are re-enabled.

### 3.4. `lib/services/preferences_service.dart`

This service manages all interactions with `SharedPreferences`, which is a plugin for storing simple key-value data persistently across app launches.

#### `PreferencesService` class

This class is implemented as a singleton and provides a type-safe API for reading and writing simple user preferences.

-   **Purpose:** To abstract the `shared_preferences` plugin and provide a clean, centralized place for managing all key-value data. This avoids scattering preference keys and `SharedPreferences` calls throughout the codebase.
-   **Key Methods:**
    -   **`getInstance()` (static method):** The method to get the singleton instance of the service.
    -   **`saveUserName(String name)` / `getUserName()`**: Methods to save and retrieve the user's name.
    -   **`isFirstLaunch()` / `setFirstLaunchComplete()`**: Methods to check if the user is opening the app for the first time and to update that flag. This is used to decide whether to show the `WelcomeScreen`.
    -   **`getLastResetDate()` / `setLastResetDate(String date)`**: Methods to store and retrieve the date on which the routine tasks were last reset. This is crucial for the daily reset logic in `HomeScreen`.
    -   **`areNotificationsEnabled()` / `setNotificationsEnabled(bool enabled)`**: Methods to get and set the user's preference for receiving notifications.
    -   **`clearUserData()`**: A method to remove all user-related data from `SharedPreferences`, used during the "Clear All Data" process in `SettingsScreen`.
-   **Error Handling:** Similar to the `DatabaseService`, all public methods are wrapped in `try...catch` blocks that log errors and throw a user-friendly `AppException`.

### 3.5. `lib/services/share_service.dart`

This service provides methods for sharing content from the app using the native platform sharing capabilities. It is a utility class with static methods and wraps the `share_plus` package.

#### `ShareService` class

-   **Purpose:** To provide a simple and centralized API for all sharing-related functionality.
-   **Key Methods:**
    -   **`shareApp()` (static method):** Shares a predefined text about the application. This is used in the `SettingsScreen`.
    -   **`shareTask(String taskTitle, ...)` (static method):** Shares the details of a single task. This could be used from a task's detail screen or context menu.

### 3.6. `lib/services/stats_service.dart`

This service encapsulates all the business logic for calculating statistics and generating data for the visualizations shown on the `StatsScreen`.

#### `StatsService` class

This class is a singleton that provides methods for data analysis. It takes a list of `Task` objects as input and returns structured data, such as maps for heatmaps or a map of overall statistics.

-   **Purpose:** To keep complex calculation logic out of the UI widgets. This makes the `StatsScreen` widget much cleaner and easier to read, and it makes the calculation logic itself more reusable and testable.
-   **Key Methods:**
    -   **`calculateCompletionHeatmapData(List<Task> tasks)`**: Processes a list of tasks and returns a map where each key is a `DateTime` (normalized to the day) and the value is the number of tasks completed on that day. This data directly powers the "Task Completion Activity" heatmap.
    -   **`calculateCreationCompletionHeatmapData(List<Task> tasks)`**: Returns a map where each key is a `DateTime` and the value is another map containing the count of tasks `created` and `completed` on that day. This powers the "Task Creation vs Completion" heatmap.
    -   **`calculateOverallStats(List<Task> tasks)`**: Computes a summary of key statistics, such as total tasks, completion rate, and the user's current streak.
    -   **`getHeatmapIntensityColor(...)`**: A helper method that calculates a color intensity based on a value, which is used by the `HeatmapWidget` to color its cells.

### 3.7. `lib/services/task_cleanup_service.dart`

This service is responsible for a background maintenance task: cleaning up old, completed tasks from the database.

#### `TaskCleanupService` class

This is a singleton service that contains the logic for identifying and deleting old tasks.

-   **Purpose:** To prevent the local database from growing indefinitely with old, completed tasks. This helps maintain app performance and keeps the user's active task list relevant.
-   **Key Methods:**
    -   **`performCleanup(DatabaseService databaseService)`**: The main method that orchestrates the cleanup process. It fetches all tasks, identifies which ones should be deleted, and then removes them from the database.
    -   **`getTasksToCleanup(List<Task> tasks)`**: A helper method that filters a list of tasks based on the cleanup criteria.
    -   **`_shouldCleanupTask(Task task, DateTime thresholdDate)` (private method):** The core logic for deciding if a single task should be deleted. It checks if a task is completed, is not a routine task, and was completed before the cleanup threshold (e.g., more than 2 months ago).

## 4. `lib/providers/`

This directory is the core of the app's state management. It contains all the `Riverpod` providers that supply data and services to the UI. Using providers decouples the UI from the business logic and data sources, making the app more modular and testable.

### 4.1. `lib/providers/provider_observer.dart`

This file contains a custom `ProviderObserver`, which is a Riverpod class that allows you to listen to the lifecycle events of all providers in the application.

#### `AppProviderObserver` class

-   **Purpose:** This class is used for debugging and logging. It hooks into Riverpod's state changes and logs them to the console. This is incredibly useful during development to see when providers are created, updated, or disposed of, and to catch any errors that occur within a provider.
-   **Key Methods (Overrides):**
    -   **`didAddProvider(...)`**: Logs when a provider is initialized.
    -   **`didUpdateProvider(...)`**: Logs when a provider's state changes, showing the previous and new values.
    -   **`didDisposeProvider(...)`**: Logs when a provider is disposed.
    -   **`providerDidFail(...)`**: Logs any errors that happen inside a provider, ensuring they are not swallowed silently.
-   **Usage:** An instance of this observer is passed to the `ProviderScope` widget in `lib/main.dart` to activate it for the entire application.

### 4.2. `lib/providers/providers.dart`

This is the main file for defining the application's Riverpod providers. It acts as a central registry for accessing services, data streams, and state notifiers from the UI.

#### Service Providers

These providers expose the application's singleton services to the rest of the app.

-   **`asyncDatabaseServiceProvider`**: A `FutureProvider` that asynchronously initializes and provides the singleton instance of `DatabaseService`. The UI can `watch` this provider to get the database service once it's ready.
-   **`asyncPreferencesServiceProvider`**: A `FutureProvider` that provides the singleton instance of `PreferencesService`.
-   **`notificationServiceProvider`**: A simple `Provider` that provides the singleton instance of `NotificationService`.
-   **`statsServiceProvider`**: A `Provider` that provides the `StatsService`.

#### Data Providers

These providers fetch data from the services and make it available to the UI. They are mostly `FutureProvider`s, which handle the asynchronous nature of fetching data, including loading and error states.

-   **`userNameProvider`**: Fetches the current user's name from `PreferencesService`.
-   **`allTasksProvider`**: Fetches a list of all `Task` objects from the `DatabaseService`. This is the source for many other providers.
-   **`everydayTasksProvider` & `routineTasksProvider`**: These providers fetch the tasks and then sort them by priority before providing them to the UI.
-   **`allAchievementsProvider`**: Fetches the list of all achievements from the `AchievementService`.
-   **`completionHeatmapDataProvider`**: Watches the `allTasksProvider` to get the tasks, then uses the `statsServiceProvider` to calculate the heatmap data. This is a great example of a provider that depends on other providers.

#### State Notifier Providers

These providers expose `StateNotifier` classes, which are used for managing more complex state that can be changed by user interaction.

-   **`asyncTaskStateNotifierProvider`**: A `FutureProvider` that creates and provides an instance of `TaskStateNotifier` (which we'll see in the next file). This notifier contains all the methods for adding, updating, and deleting tasks.
-   **`asyncUserStateNotifierProvider`**: Provides an instance of `UserStateNotifier`, which handles saving the user's name.

### 4.3. `lib/providers/task_state_notifier.dart`

This file contains the `TaskStateNotifier`, a key component of the app's state management system. It's responsible for handling all business logic related to task manipulation.

#### `TaskState` class

A simple, immutable class that represents the state of the task-related data.

-   **Purpose:** To hold the lists of tasks, the current loading state, and any errors. The UI will rebuild whenever a new `TaskState` is emitted.
-   **Properties:**
    -   `everydayTasks`: The current list of everyday tasks.
    -   `routineTasks`: The current list of routine tasks.
    -   `isLoading`: A boolean to indicate if a task operation is in progress.
    -   `error`: A string to hold any error message.

#### `TaskStateNotifier` class

A `StateNotifier` that manages the `TaskState`.

-   **Purpose:** To provide a single place to handle all task-related actions, such as adding, updating, and deleting tasks. It orchestrates calls to the `DatabaseService`, `NotificationService`, and `AchievementService` to perform these actions.
-   **Dependencies:** It takes instances of `DatabaseService`, `AchievementService`, and `NotificationService` in its constructor, which are provided by other Riverpod providers.
-   **Key Methods:**
    -   **`loadTasks()`**: Fetches all tasks from the `DatabaseService` and updates the state. This is called when the notifier is first created.
    -   **`addTask(Task task)`**: Adds a new task. It calls the `DatabaseService` to save the task, schedules a notification if needed via the `NotificationService`, reloads the task list, and then triggers an achievement check via the `AchievementService`.
    -   **`updateTask(Task task)`**: Updates an existing task, including rescheduling notifications if the time has changed.
    -   **`deleteTask(int taskId)`**: Deletes a task and cancels any associated notification.
    -   **`toggleTaskCompletion(int taskId)`**: Toggles the completion status of a task and updates the state accordingly.
-   **State Management:** After each operation, the notifier calls `loadTasks()` to fetch the latest state from the database and then updates its `state` property. Any widget watching the `asyncTaskStateNotifierProvider` will automatically rebuild with the new state.

### 4.4. `lib/providers/user_state_notifier.dart`

This file contains the `UserStateNotifier`, which is responsible for managing the user's state, such as their name and whether they have completed the initial onboarding.

#### `UserState` class

An immutable class that represents the current state of the user.

-   **Purpose:** To hold user-specific state information.
-   **Properties:**
    -   `userName`: The current user's name.
    -   `isAuthenticated`: A boolean indicating if the user has provided a name. In this app, this is equivalent to being "logged in".
    -   `isFirstLaunch`: A boolean to track if the app has been launched before.
    -   `isLoading`: A boolean to indicate if a user operation is in progress.

#### `UserStateNotifier` class

A `StateNotifier` that manages the `UserState`.

-   **Purpose:** To handle the logic for user onboarding and data clearing.
-   **Dependencies:** It takes an instance of `PreferencesService` to save and retrieve user data.
-   **Key Methods:**
    -   **`loadUserData()`**: Called when the notifier is created, it loads the user's name and launch status from `PreferencesService` to initialize the state.
    -   **`saveUserName(String name)`**: Saves the user's name using `PreferencesService`, marks the first launch as complete, and updates the state to reflect that the user is now "authenticated".
    -   **`clearUserData()`**: Clears all user data from `PreferencesService` and resets the `UserState` to its initial, unauthenticated values. This is used by the "Clear All Data" feature.

## 5. `lib/widgets/`

This directory contains all the reusable UI components (widgets) that are used to build the application's screens. Creating reusable widgets helps to avoid code duplication and ensures a consistent look and feel across the app.

### 5.1. `lib/widgets/achievement_widget.dart`

This file contains the `AchievementWidget`, which is responsible for displaying a single achievement in a list.

#### `AchievementWidget` class

A stateless widget that visually represents an `Achievement` model.

-   **Purpose:** To provide a consistent UI for displaying both earned and unearned achievements on the `StatsScreen`.
-   **Key Parameters:**
    -   `achievement`: The `Achievement` object containing the data to display.
    -   `isEarned`: A boolean that controls the visual style of the widget. The widget has a different appearance for earned vs. unearned achievements (e.g., different border colors, an "Earned" badge).
    -   `progress`: A double representing the user's progress towards the achievement, used for the progress bar.
-   **UI Logic:**
    -   It displays the achievement's icon, title, and description.
    -   If the achievement is not earned, it shows a `LinearProgressIndicator` to visualize the user's progress.
    -   If the achievement is earned, it displays the date it was earned and a prominent "Earned" badge.

### 5.2. `lib/widgets/add_task_dialog.dart`

This file contains the UI and logic for the dialog that allows users to add a new task or edit an existing one.

#### `AddTaskDialog` class

A `ConsumerStatefulWidget` that builds the dialog's UI and handles its state.

-   **Purpose:** To provide a form for users to input task details. It handles both creation and editing modes.
-   **Key Parameters:**
    -   `task`: An optional `Task` object. If provided, the dialog enters "edit" mode and pre-fills the form with the task's data. If `null`, it's in "add" mode.
    -   `isRoutineTask`: A boolean to indicate if a new task should be created as a routine task.
    -   `onTaskSaved`: A callback function that is executed after a task is successfully saved, allowing the calling widget to react (e.g., by refreshing its data).
-   **State Management:**
    -   It uses a `GlobalKey<FormState>` to manage and validate the form.
    -   It uses `TextEditingController` for the title input.
    -   It manages local state for the "Routine" toggle and the selected priority using `setState`.
-   **Functionality:**
    -   It displays a title, a text field for the task title, a toggle for "Routine" tasks, and a dropdown for setting the task's priority.
    -   When the user saves, the `_saveTask` method is called. This method validates the form, creates a new `Task` object (or updates the existing one), and then calls the appropriate method on the `TaskStateNotifier` (obtained via `ref.read`) to persist the change.
    -   It shows a loading indicator while the save operation is in progress.

#### Helper Functions

-   **`showAddTaskDialog(...)` & `showEditTaskDialog(...)`**: These are top-level helper functions that wrap the `showDialog` call. They provide a clean and simple way to launch the dialog from anywhere in the app.

### 5.3. `lib/widgets/app_icon.dart`

This file contains widgets related to displaying the application's icon and logo.

#### `AppIcon` class

A simple, stateless widget that displays the app's icon.

-   **Purpose:** To provide a reusable and consistently styled app icon.
-   **Key Parameters:**
    -   `size`: The size of the icon container.
    -   `showBackground`: A boolean to control whether the icon has a styled background container or is just the plain icon.

#### `AppLogo` class

A stateless widget that combines the `AppIcon` with the app's name.

-   **Purpose:** To display the full app logo, which is used on the `WelcomeScreen`.
-   **Key Parameters:**
    -   `iconSize`: The size of the icon part of the logo.
    -   `appName`: The text to display next to the icon.
    -   `direction`: An `Axis` to lay out the icon and text either vertically or horizontally.

#### `AnimatedAppIcon` class

A stateful widget that wraps the `AppIcon` and adds a subtle pulsing animation.

-   **Purpose:** To provide a visually engaging icon for loading screens, such as the initial `AppInitializer` screen in `main.dart`.
-   **Key Parameters:**
    -   `isAnimating`: A boolean to control whether the animation is currently active.
    -   `duration`: The duration of one cycle of the animation.

### 5.4. `lib/widgets/compact_task_widget.dart`

This file contains the `CompactTaskWidget`, a major component used on the `HomeScreen` to display lists of tasks in a collapsible container.

#### `CompactTaskWidget` class

A `ConsumerStatefulWidget` that displays a list of either "Everyday" or "Routine" tasks.

-   **Purpose:** To provide a compact, expandable view of a task list. It shows a limited number of tasks initially and allows the user to expand it to see the full list.
-   **Key Parameters:**
    -   `title`: The title displayed in the widget's header (e.g., "Today's Tasks").
    -   `showRoutineTasks`: A boolean that determines which list of tasks to display. If `true`, it watches the `routineTasksProvider`; otherwise, it watches the `everydayTasksProvider`.
    -   `maxTasksWhenCollapsed`: The number of tasks to show when the list is collapsed.
    -   `onTaskToggle`, `onTaskEdit`, `onTaskDelete`: Callback functions that are passed down to the individual `TaskItem` widgets. This allows the parent screen (`HomeScreen`) to handle the logic for these actions.
-   **State Management:**
    -   It uses `ref.watch` to listen to the appropriate task provider (`everydayTasksProvider` or `routineTasksProvider`) and automatically rebuilds when the task list changes.
    -   It manages its own `_isExpanded` state locally using `setState` to control the expand/collapse functionality.
    -   It uses an `AnimationController` to animate the "Show More/Less" button's icon.
-   **UI Logic:**
    -   It displays a header with the title and an "Add" button.
    -   It renders a list of `TaskItem` widgets.
    -   If the total number of tasks exceeds `maxTasksWhenCollapsed`, it displays a "Show More" button, which expands the list when tapped.

### 5.5. `lib/widgets/custom_app_bar.dart`

This file provides a reusable, custom `AppBar` widget to ensure a consistent look and feel for the top navigation bar across different screens.

#### `CustomAppBar` class

A stateless widget that implements `PreferredSizeWidget` to be used as an `AppBar`.

-   **Purpose:** To provide a standard `AppBar` with the app's title and an optional share button.
-   **Key Parameters:**
    -   `title`: The text to display as the title of the `AppBar`.
    -   `showShareButton`: A boolean to control the visibility of the share action button.
    -   `onSharePressed`: An optional callback to override the default share behavior. If not provided, it calls `ShareService.shareApp()`.
    -   `additionalActions`: A list of other widgets to display as actions in the `AppBar`.

#### `CustomAppBarWithBack` class

A convenient wrapper around `CustomAppBar` that automatically includes a back button.

-   **Purpose:** To be used on secondary screens that require navigation back to the previous screen.
-   **Functionality:** It renders a `CustomAppBar` and places an `IconButton` with a back arrow in the `leading` position. The `onPressed` callback for the back button defaults to `Navigator.of(context).pop()`.

### 5.6. `lib/widgets/custom_text_field.dart`

This file provides a reusable, custom-styled text field widget.

#### `CustomTextField` class

A stateless widget that wraps a `TextFormField` and applies a consistent style from the app's theme.

-   **Purpose:** To avoid duplicating text field styling code across multiple forms. It ensures that all text fields in the app have the same look and feel (e.g., border, colors, text styles).
-   **Functionality:** It takes all the standard `TextFormField` parameters (like `controller`, `validator`, `onChanged`, `keyboardType`, etc.) and passes them to the underlying `TextFormField`. It then applies a custom `InputDecoration` that uses the colors and constants defined in `AppTheme`.

### 5.7. `lib/widgets/error_boundary.dart`

This file provides an "Error Boundary" widget, which is a concept borrowed from web frameworks like React. It's a widget that catches errors that occur in its child widget tree, preventing the entire app from crashing and allowing you to display a user-friendly fallback UI instead.

#### `ErrorBoundary` class

A stateful widget that wraps a child widget in a `try...catch` block.

-   **Purpose:** To isolate errors to a specific part of the UI. If an error occurs while building the `child` widget, the `ErrorBoundary` catches it, logs it, and displays a fallback UI instead of showing a red screen of death.
-   **Key Parameters:**
    -   `child`: The widget tree to protect.
    -   `fallback`: An optional custom widget to display when an error occurs. If not provided, it defaults to the `ErrorDisplayWidget`.
    -   `onRetry`: An optional callback that allows the user to try and rebuild the `child` widget again.
-   **Functionality:** It uses a `Builder` to wrap the `child` in a `try...catch`. If an exception is caught, it updates its local state (`_hasError = true`) and rebuilds to show the fallback UI.

### 5.8. `lib/widgets/heatmap_widget.dart`

This file contains the `HeatmapWidget`, a sophisticated, reusable widget for visualizing time-series data on a calendar-like grid.

#### `HeatmapWidget` class

A stateful widget that takes a map of dates to values and renders it as a heatmap.

-   **Purpose:** To provide the calendar-style heatmaps on the `StatsScreen` for visualizing task completion and creation activity.
-   **Key Parameters:**
    -   `data`: The input data, which is a `Map<DateTime, int>`. Each entry represents a day and its corresponding value (e.g., number of tasks completed).
    -   `baseColor`: The `Color` used for the cells with the highest intensity. The widget calculates shades of this color for other values.
    -   `title`: A title to display above the heatmap.
    -   `onCellTap`: An optional callback that is triggered when a user taps on a day's cell.
    -   `tooltipBuilder`: An optional function that builds a custom widget to be displayed as a tooltip when a user taps on a cell.
-   **Functionality:**
    -   It lays out a grid of cells representing the days of the year, organized by month.
    -   For each day, it looks up the corresponding value from the `data` map.
    -   It calculates an intensity (from 0.0 to 1.0) based on the day's value relative to the maximum value in the entire dataset.
    -   It uses this intensity to `lerp` (linearly interpolate) between a default gray color and the `baseColor`, creating the heatmap effect.
    -   It includes a legend to help the user understand the color intensity.
    -   It has a built-in tooltip system that shows more detailed information when a cell is tapped.

### 5.9. `lib/widgets/task_container.dart`

This file contains the `TaskContainer` widget, a component designed to display a list of tasks for a specific date. *Note: This widget is not currently used in the main UI but is available for future use.*

#### `TaskContainer` class

A stateless widget that displays a list of tasks within a styled container.

-   **Purpose:** To provide a container for a day's tasks, complete with a header showing the date and an "Add" button.
-   **Key Parameters:**
    -   `date`: The `DateTime` for which to display tasks.
    -   `tasks`: The `List<Task>` to be displayed.
    -   `onAddTask`, `onTaskToggle`, `onTaskEdit`, `onTaskDelete`: Callback functions to handle user interactions with the tasks.
-   **Functionality:**
    -   It displays a header with a formatted date (e.g., "Today", "Yesterday", or "Mon, Jan 1") and an "Add" button.
    -   It renders a `ListView` of `TaskItem` widgets for the provided tasks.
    -   If the list of tasks is empty, it displays a user-friendly "No tasks for today" message.
    -   The tasks are sorted by priority before being displayed.

### 5.10. `lib/widgets/task_item.dart`

This file contains the `TaskItem` widget, which is responsible for rendering a single task in a list.

#### `TaskItem` class

A stateless widget that displays the details of a `Task` object and provides interactive controls.

-   **Purpose:** To be the standard representation of a task in any list (`CompactTaskWidget`, `TaskContainer`, etc.).
-   **Key Parameters:**
    -   `task`: The `Task` object to display.
    -   `onToggle`: A callback function that is triggered when the user taps the checkbox.
    -   `onEdit`: A callback that is triggered when the user taps the edit button.
    -   `onDelete`: A callback that is triggered when the user taps the delete button.
-   **UI Logic:**
    -   It displays a checkbox to show and control the `isCompleted` status.
    -   It shows the task's title and description. If the text is long, it is truncated using the `TruncatedText` widget.
    -   The text has a line-through decoration if the task is completed.
    -   It displays a small "Routine" chip if the task is a routine task.
    -   It has a subtle colored bar on the left to indicate the task's priority.
    -   It includes "Edit" and "Delete" buttons.

### 5.11. `lib/widgets/truncated_text.dart`

This file provides a widget for displaying long text that can be truncated and expanded by the user.

#### `TruncatedText` class

A stateful widget that displays text and provides a "Show more" / "Show less" button if the text exceeds a certain length.

-   **Purpose:** To prevent long task descriptions from taking up too much screen space, while still allowing the user to view the full text if they choose.
-   **Key Parameters:**
    -   `text`: The full string to be displayed.
    -   `maxLength`: The number of characters to show before truncating the text.
-   **Functionality:**
    -   It checks if the length of the `text` is greater than `maxLength`.
    -   If it is, it initially shows only a substring of the text and a "Show more" button.
    -   When the user taps the widget, it expands to show the full text and changes the button to "Show less".

#### `SimpleTruncatedText` class

A simpler, stateless version that truncates text but shows the full text in a tooltip on tap instead of expanding in place.

-   **Purpose:** Useful for single-line text that might overflow, like titles.
-   **Functionality:** If the text is truncated, it wraps the `Text` widget in a `Tooltip` widget, so the user can long-press (or hover) to see the full text.

## 6. `lib/screens/`

This directory contains the top-level widgets for each screen in the application. These widgets are responsible for laying out the screen's UI and bringing together the various services, providers, and reusable widgets to create a functional user experience.

### 6.1. `lib/screens/welcome_screen.dart`

This file contains the `WelcomeScreen`, which is the first screen shown to new users.

#### `WelcomeScreen` class

A `ConsumerStatefulWidget` that handles the user onboarding process.

-   **Purpose:** To collect the user's name and save it, completing the initial setup.
-   **UI Composition:**
    -   It uses the `AppIcon` widget to display the app's logo.
    -   It uses the `CustomTextField` widget for the name input field.
    -   The layout is responsive, using methods from `ResponsiveUtils` to adjust sizes and spacing.
-   **State and Logic:**
    -   It uses a `GlobalKey<FormState>` to validate the name input field.
    -   The `_saveNameAndNavigate` method is the core of its logic. When the "Get Started" button is pressed, this method:
        1.  Validates the form.
        2.  Reads the `UserStateNotifier` using `ref.read(asyncUserStateNotifierProvider.future)`.
        3.  Calls the `saveUserName` method on the notifier to persist the name.
        4.  Navigates the user to the main app screen (`/main`) upon success.
    -   It uses the `asyncUserStateNotifierProvider` to handle its own loading and error states while the `PreferencesService` is initializing.

### 6.2. `lib/screens/main_navigation_screen.dart`

This file contains the `MainNavigationScreen`, which is the main hub of the application after the user is onboarded.

#### `MainNavigationScreen` class

A `StatefulWidget` that implements the main navigation structure using a bottom navigation bar.

-   **Purpose:** To allow the user to switch between the three main sections of the app: Home, Stats, and Settings.
-   **UI Composition:**
    -   The body of the `Scaffold` is a `PageView`, which allows for horizontal swiping between screens.
    -   The `bottomNavigationBar` is a custom-styled `BottomNavigationBar` with three tabs.
-   **State and Logic:**
    -   It holds a list of the three main screen widgets: `HomeScreen`, `StatsScreen`, and `SettingsScreen`.
    -   It uses a `PageController` to keep the `PageView` in sync with the `BottomNavigationBar`.
    -   The `_currentIndex` in the local state tracks the currently active tab.
    -   The `_onTabSelected` method handles taps on the navigation bar items, animating the `PageView` to the corresponding screen.
    -   The `_onPageChanged` method listens for swipes on the `PageView` and updates the selected tab in the navigation bar to match.

### 6.3. `lib/screens/home_screen.dart`

This file contains the `HomeScreen`, the main screen of the app where users manage their tasks.

#### `HomeScreen` class

A `ConsumerStatefulWidget` that serves as the primary task management interface.

-   **Purpose:** To display the user's tasks, provide a personalized greeting, and allow for task interactions.
-   **UI Composition:**
    -   It uses a `CustomAppBar` for the top navigation bar.
    -   The body is a `SingleChildScrollView` containing a greeting and two instances of the `CompactTaskWidget`.
    -   One `CompactTaskWidget` is configured to show "Today's Tasks" (`showRoutineTasks: false`).
    -   The other `CompactTaskWidget` is configured to show "Routine Tasks" (`showRoutineTasks: true`).
-   **State and Logic:**
    -   **Daily Reset:** In its `initState`, it calls the `_initializeDailyTasks` method. This method checks the `PreferencesService` to see if the routine tasks have already been generated for the current day. If not, it calls `DatabaseService.createDailyRoutineTaskInstances()` to create them. This is a critical piece of the app's core logic.
    -   **Greeting:** The `_buildGreeting` method watches the `userNameProvider` to get the user's name and displays a personalized, time-sensitive greeting.
    -   **Task Callbacks:** It defines the methods (`_onTaskToggle`, `_onTaskEdit`, `_onTaskDelete`) that are passed as callbacks to the `CompactTaskWidget`. These methods are responsible for calling the appropriate functions on the `TaskStateNotifier` to perform the actions and then showing a `SnackBar` with the result.
    -   **Dialogs:** It uses the `showEditTaskDialog` helper function to open the task editing dialog. It also contains the logic for showing the delete confirmation dialog.

### 6.4. `lib/screens/stats_screen.dart`

This file contains the `StatsScreen`, which provides users with a dashboard of their productivity statistics and achievements.

#### `StatsScreen` class

A `ConsumerWidget` that builds the entire statistics UI.

-   **Purpose:** To visualize user data in an engaging way, helping users to understand their habits and stay motivated.
-   **UI Composition:**
    -   It uses a `GridView` to display a set of overview statistic cards (e.g., "Total Tasks", "Completed").
    -   It uses two instances of the `HeatmapWidget` to display the task completion and creation/completion heatmaps.
    -   It uses a `ListView` of `AchievementWidget`s to display the list of earned and unearned achievements.
-   **State and Logic:**
    -   The entire screen is reactive. It `watch`es several providers to get the data it needs:
        -   `allTasksProvider`: To get the raw task data for calculating stats.
        -   `completionHeatmapDataProvider` & `creationCompletionHeatmapDataProvider`: To get the pre-calculated data for the heatmaps.
        -   `allAchievementsProvider`: To get the list of achievements to display.
    -   It uses the `when` method on the async providers to handle loading and error states gracefully, showing progress indicators or error messages as needed.
    -   The `_calculateStats` private method contains the logic to process the raw task list into the simple statistics shown at the top of the screen. This is a good example of UI-specific logic that doesn't need to live in a separate service.

### 6.5. `lib/screens/settings_screen.dart`

This file contains the `SettingsScreen`, where users can configure app-level settings, manage their data, and find information about the app.

#### `SettingsScreen` class

A `ConsumerStatefulWidget` that builds a list of settings options.

-   **Purpose:** To provide a centralized location for all user-configurable options.
-   **UI Composition:**
    -   The UI is a `ListView` of settings items, grouped into sections (e.g., "App", "Notifications", "Data").
    -   It uses helper methods like `_buildSettingsSection` and `_buildSettingsItem` to create a consistent look for each setting.
-   **State and Logic:**
    -   **Notification Toggle:** It watches the `notificationsEnabledProvider` to show the current status of the notification toggle. When the user changes the toggle, the `_handleNotificationToggle` method is called, which in turn calls the `NotificationService` to enable/disable and schedule/cancel all notifications, and the `PreferencesService` to persist the setting.
    -   **Share App:** The "Share App" item calls the static `ShareService.shareApp()` method.
    -   **Clear All Data:** This is the most complex operation. The `_handleClearAllData` method:
        1.  Shows a confirmation dialog to the user.
        2.  If confirmed, it calls the `DatabaseService` to delete all tasks.
        3.  It then calls the `PreferencesService` to clear all user data.
        4.  Finally, it navigates the user back to the `WelcomeScreen`, effectively resetting the app.
    -   It uses `ref.watch` on several providers (`userNameProvider`, `notificationsEnabledProvider`, `notificationPermissionStatusProvider`) to reactively display the current state of the app's settings.
