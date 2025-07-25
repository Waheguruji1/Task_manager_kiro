import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/widgets/add_task_dialog.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('AddTaskDialog Tests', () {
    testWidgets('should display add task dialog correctly', (WidgetTester tester) async {
      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddTaskDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog elements are present
      expect(find.text('Add New Task'), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Routine Task'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
    });

    testWidgets('should display edit task dialog correctly', (WidgetTester tester) async {
      final testTask = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        isRoutine: true,
        createdAt: DateTime.now(),
      );

      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEditTaskDialog(context, task: testTask),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog elements are present
      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      
      // Verify task data is pre-filled
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should validate required title field', (WidgetTester tester) async {
      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddTaskDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to save without entering title
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter a task title'), findsOneWidget);
    });

    testWidgets('should toggle routine task switch', (WidgetTester tester) async {
      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddTaskDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find and tap the switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      
      // Get initial switch value (should be false)
      Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, false);

      // Tap the switch to toggle it
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify switch is now true
      switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, true);
    });

    testWidgets('should close dialog when cancel is pressed', (WidgetTester tester) async {
      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddTaskDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Add New Task'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Add New Task'), findsNothing);
    });
  });
}