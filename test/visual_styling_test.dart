import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/widgets/task_item.dart';
import 'package:task_manager_kiro/widgets/task_container.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('Visual Styling Tests', () {
    testWidgets('TaskItem should show visual distinction for routine tasks', (WidgetTester tester) async {
      // Create routine and everyday tasks
      final routineTask = Task(
        id: 1,
        title: 'Routine Task',
        description: 'This is a routine task',
        isRoutine: true,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final everydayTask = Task(
        id: 2,
        title: 'Everyday Task',
        description: 'This is an everyday task',
        isRoutine: false,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Build routine task item
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Column(
              children: [
                TaskItem(
                  task: routineTask,
                  onToggle: (value) {},
                  onEdit: () {},
                  onDelete: () {},
                ),
                TaskItem(
                  task: everydayTask,
                  onToggle: (value) {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify routine task has routine indicator
      expect(find.text('Routine'), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);

      // Verify task titles are displayed
      expect(find.text('Routine Task'), findsOneWidget);
      expect(find.text('Everyday Task'), findsOneWidget);
    });

    testWidgets('TaskContainer should show empty state when no tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskContainer(
              date: DateTime.now(),
              tasks: const [],
              onAddTask: () {},
              onTaskToggle: (task) {},
              onTaskEdit: (task) {},
              onTaskDelete: (task) {},
            ),
          ),
        ),
      );

      // Verify empty state is shown
      expect(find.text('No tasks for today'), findsOneWidget);
      expect(find.text('Tap the + button to add your first task'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
    });

    testWidgets('TaskContainer should show add button with proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskContainer(
              date: DateTime.now(),
              tasks: const [],
              onAddTask: () {},
              onTaskToggle: (task) {},
              onTaskEdit: (task) {},
              onTaskDelete: (task) {},
            ),
          ),
        ),
      );

      // Verify add button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      // Verify date is displayed
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('TaskItem should show proper checkbox styling for completed tasks', (WidgetTester tester) async {
      final completedTask = Task(
        id: 1,
        title: 'Completed Task',
        isCompleted: true,
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: completedTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify checkbox is present and checked
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // Verify task title has strikethrough for completed tasks
      final titleText = tester.widget<Text>(find.text('Completed Task'));
      expect(titleText.style?.decoration, TextDecoration.lineThrough);
    });
  });
}