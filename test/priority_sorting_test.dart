import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';

void main() {
  group('Priority Sorting Tests', () {
    test('should sort tasks by priority correctly', () {
      // Create test tasks with different priorities
      final tasks = [
        Task(
          id: 1,
          title: 'No Priority Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.none,
        ),
        Task(
          id: 2,
          title: 'High Priority Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
        ),
        Task(
          id: 3,
          title: 'Medium Priority Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.medium,
        ),
        Task(
          id: 4,
          title: 'Another High Priority Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
        ),
        Task(
          id: 5,
          title: 'Another No Priority Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.none,
        ),
      ];

      // Sort tasks by priority
      final sortedTasks = Task.sortByPriority(tasks);

      // Verify the sorting order: High → Medium → No Priority
      expect(sortedTasks[0].priority, TaskPriority.high);
      expect(sortedTasks[1].priority, TaskPriority.high);
      expect(sortedTasks[2].priority, TaskPriority.medium);
      expect(sortedTasks[3].priority, TaskPriority.none);
      expect(sortedTasks[4].priority, TaskPriority.none);

      // Verify specific task IDs to ensure correct ordering
      expect(sortedTasks[0].id, 2); // First high priority task
      expect(sortedTasks[1].id, 4); // Second high priority task
      expect(sortedTasks[2].id, 3); // Medium priority task
      expect(sortedTasks[3].id, 1); // First no priority task
      expect(sortedTasks[4].id, 5); // Second no priority task
    });

    test('should return correct priority colors', () {
      final highPriorityTask = Task(
        title: 'High Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      final mediumPriorityTask = Task(
        title: 'Medium Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );

      final noPriorityTask = Task(
        title: 'No Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
      );

      // Test priority colors
      expect(highPriorityTask.priorityColor, const Color(0xFF8B5CF6)); // Purple
      expect(mediumPriorityTask.priorityColor, const Color(0xFF10B981)); // Green
      expect(noPriorityTask.priorityColor, Colors.transparent);
    });

    test('should return correct priority order values', () {
      final highPriorityTask = Task(
        title: 'High Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      final mediumPriorityTask = Task(
        title: 'Medium Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );

      final noPriorityTask = Task(
        title: 'No Priority',
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
      );

      // Test priority order values (lower values = higher priority)
      expect(highPriorityTask.priorityOrder, 0);
      expect(mediumPriorityTask.priorityOrder, 1);
      expect(noPriorityTask.priorityOrder, 2);
    });

    test('should handle empty task list', () {
      final emptyTasks = <Task>[];
      final sortedTasks = Task.sortByPriority(emptyTasks);
      
      expect(sortedTasks, isEmpty);
    });

    test('should handle single task', () {
      final singleTask = [
        Task(
          title: 'Single Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.medium,
        ),
      ];
      
      final sortedTasks = Task.sortByPriority(singleTask);
      
      expect(sortedTasks.length, 1);
      expect(sortedTasks[0].priority, TaskPriority.medium);
    });

    test('should handle tasks with same priority', () {
      final samePriorityTasks = [
        Task(
          id: 1,
          title: 'High Priority Task 1',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
        ),
        Task(
          id: 2,
          title: 'High Priority Task 2',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
        ),
        Task(
          id: 3,
          title: 'High Priority Task 3',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
        ),
      ];
      
      final sortedTasks = Task.sortByPriority(samePriorityTasks);
      
      expect(sortedTasks.length, 3);
      // All tasks should have high priority
      for (final task in sortedTasks) {
        expect(task.priority, TaskPriority.high);
      }
    });
  });
}