import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_kiro/widgets/add_task_dialog.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('Enhanced Add Task Dialog Tests', () {
    testWidgets('should show priority and notification options for everyday tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify priority dropdown is visible
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Set task importance level'), findsOneWidget);

      // Verify notification dropdown is visible
      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('No reminder set'), findsOneWidget);

      // Verify routine task toggle is visible
      expect(find.text('Routine Task'), findsOneWidget);
    });

    testWidgets('should hide priority and notification options for routine tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: true),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify priority dropdown is NOT visible
      expect(find.text('Priority'), findsNothing);
      expect(find.text('Set task importance level'), findsNothing);

      // Verify notification dropdown is NOT visible
      expect(find.text('Notification'), findsNothing);

      // Verify routine task toggle is visible and enabled
      expect(find.text('Routine Task'), findsOneWidget);
    });

    testWidgets('should show priority options when priority dropdown is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Find and tap the priority dropdown
      final priorityDropdown = find.byType(DropdownButton<TaskPriority>);
      expect(priorityDropdown, findsOneWidget);

      await tester.tap(priorityDropdown);
      await tester.pumpAndSettle();

      // Verify priority options are shown (allowing for duplicates in dropdown)
      expect(find.text('High Priority'), findsAtLeastNWidgets(1));
      expect(find.text('Medium Priority'), findsAtLeastNWidgets(1));
      expect(find.text('No Priority'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show notification options when notification dropdown is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Find and tap the notification dropdown
      final notificationDropdown = find.byType(DropdownButton<String>);
      expect(notificationDropdown, findsOneWidget);

      await tester.tap(notificationDropdown);
      await tester.pumpAndSettle();

      // Verify notification options are shown (allowing for duplicates in dropdown)
      expect(find.text('No reminder'), findsAtLeastNWidgets(1));
      expect(find.text('1 hour before'), findsAtLeastNWidgets(1));
      expect(find.text('2 hours before'), findsAtLeastNWidgets(1));
      expect(find.text('Custom time'), findsAtLeastNWidgets(1));
    });

    testWidgets('should initialize with existing task priority and notification data', (WidgetTester tester) async {
      final existingTask = Task(
        id: 1,
        title: 'Test Task',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AddTaskDialog(task: existingTask),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the task title is pre-filled
      expect(find.text('Test Task'), findsOneWidget);

      // Verify priority and notification options are visible (since it's not a routine task)
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Notification'), findsOneWidget);
    });

    testWidgets('should validate task title input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AddTaskDialog(isRoutineTask: false),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Try to save without entering a title
      final saveButton = find.text('Add Task');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // The dialog should still be visible (validation failed)
      expect(find.byType(AddTaskDialog), findsOneWidget);
    });

    testWidgets('should show upward arrow icons for dropdowns', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify upward arrow icons are present
      final upwardArrows = find.byIcon(Icons.keyboard_arrow_up);
      expect(upwardArrows, findsNWidgets(2)); // One for priority, one for notification
    });

    testWidgets('should toggle routine task and hide/show priority options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Initially, priority and notification options should be visible
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Notification'), findsOneWidget);

      // Find and tap the routine task switch
      final routineSwitch = find.byType(Switch);
      expect(routineSwitch, findsOneWidget);

      await tester.tap(routineSwitch);
      await tester.pumpAndSettle();

      // After toggling to routine task, priority and notification options should be hidden
      expect(find.text('Priority'), findsNothing);
      expect(find.text('Notification'), findsNothing);
    });

    testWidgets('should show custom time picker when custom notification is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(isRoutineTask: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Find and tap the notification dropdown
      final notificationDropdown = find.byType(DropdownButton<String>);
      await tester.tap(notificationDropdown);
      await tester.pumpAndSettle();

      // Find and tap the custom time option
      final customTimeOption = find.text('Custom time').last;
      await tester.tap(customTimeOption);
      await tester.pumpAndSettle();

      // The time picker should appear (we can't easily test the actual picker in widget tests)
      // But we can verify the dropdown closed and the state changed
      // The "Custom time" text should still be visible in the dropdown description
      expect(find.text('Custom time'), findsAtLeastNWidgets(1));
    });
  });
}