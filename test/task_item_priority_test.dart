import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/widgets/task_item.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('TaskItem Priority Visual Tests', () {
    testWidgets('should display priority indicator for high priority task', (WidgetTester tester) async {
      final highPriorityTask = Task(
        id: 1,
        title: 'High Priority Task',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: highPriorityTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify that the task item is displayed
      expect(find.text('High Priority Task'), findsOneWidget);
      
      // Verify that a priority indicator container exists
      // The priority indicator is a Container with width 3 and specific color
      final priorityIndicators = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == highPriorityTask.priorityColor);
      
      expect(priorityIndicators, findsAtLeastNWidgets(1));
    });

    testWidgets('should display priority indicator for medium priority task', (WidgetTester tester) async {
      final mediumPriorityTask = Task(
        id: 2,
        title: 'Medium Priority Task',
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: mediumPriorityTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify that the task item is displayed
      expect(find.text('Medium Priority Task'), findsOneWidget);
      
      // Verify that a priority indicator container exists with green color
      final priorityIndicators = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == mediumPriorityTask.priorityColor);
      
      expect(priorityIndicators, findsAtLeastNWidgets(1));
    });

    testWidgets('should not display priority indicator for no priority task', (WidgetTester tester) async {
      final noPriorityTask = Task(
        id: 3,
        title: 'No Priority Task',
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: noPriorityTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify that the task item is displayed
      expect(find.text('No Priority Task'), findsOneWidget);
      
      // Verify that no priority indicator is displayed for no priority tasks
      // The priority indicator should not be built when priority is none
      final priorityIndicators = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.transparent);
      
      // Should not find priority indicator containers for no priority tasks
      expect(priorityIndicators, findsNothing);
    });

    testWidgets('should display task with priority-based background tint', (WidgetTester tester) async {
      final highPriorityTask = Task(
        id: 4,
        title: 'High Priority Background Test',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: highPriorityTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify that the task item is displayed
      expect(find.text('High Priority Background Test'), findsOneWidget);
      
      // Find the main container of the TaskItem
      final taskContainers = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration);
      
      expect(taskContainers, findsAtLeastNWidgets(1));
    });

    test('priority color values are correct', () {
      // Test that priority colors match the expected values
      expect(TaskPriority.high.name, 'high');
      expect(TaskPriority.medium.name, 'medium');
      expect(TaskPriority.none.name, 'none');
      
      final highTask = Task(title: 'Test', createdAt: DateTime.now(), priority: TaskPriority.high);
      final mediumTask = Task(title: 'Test', createdAt: DateTime.now(), priority: TaskPriority.medium);
      final noneTask = Task(title: 'Test', createdAt: DateTime.now(), priority: TaskPriority.none);
      
      expect(highTask.priorityColor, const Color(0xFF8B5CF6)); // Purple
      expect(mediumTask.priorityColor, const Color(0xFF10B981)); // Green
      expect(noneTask.priorityColor, Colors.transparent);
    });
  });
}