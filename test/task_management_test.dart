import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';

void main() {
  group('Task Management Logic Tests', () {
    test('Task creation and properties', () {
      // Test task creation
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, false);
      expect(task.isRoutine, false);
      expect(task.completedAt, isNull);
    });

    test('Routine task properties', () {
      // Test routine task creation
      final routineTask = Task(
        title: 'Daily Exercise',
        description: 'Morning workout routine',
        isRoutine: true,
        createdAt: DateTime.now(),
      );

      expect(routineTask.title, 'Daily Exercise');
      expect(routineTask.isRoutine, true);
      expect(routineTask.isCompleted, false);
    });

    test('Task completion toggle functionality', () {
      final originalTask = Task(
        id: 1,
        title: 'Original Task',
        description: 'Original Description',
        isCompleted: false,
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      // Test completion toggle
      final completedTask = originalTask.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completedTask.id, originalTask.id);
      expect(completedTask.title, originalTask.title);
      expect(completedTask.isCompleted, true);
      expect(completedTask.completedAt, isNotNull);

      // Test uncompleting task
      final uncompletedTask = completedTask.copyWith(
        isCompleted: false,
        completedAt: null,
      );

      expect(uncompletedTask.isCompleted, false);
      expect(uncompletedTask.completedAt, isNull);
    });

    test('Task editing functionality', () {
      final originalTask = Task(
        id: 1,
        title: 'Original Task',
        description: 'Original Description',
        isCompleted: false,
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      // Test task editing
      final editedTask = originalTask.copyWith(
        title: 'Updated Task',
        description: 'Updated Description',
        isRoutine: true,
      );

      expect(editedTask.id, originalTask.id);
      expect(editedTask.title, 'Updated Task');
      expect(editedTask.description, 'Updated Description');
      expect(editedTask.isRoutine, true);
      expect(editedTask.createdAt, originalTask.createdAt);
    });

    test('Daily reset date formatting', () {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      expect(todayString, isNotEmpty);
      expect(todayString.contains('-'), true);
      
      // Test different date
      final testDate = DateTime(2024, 1, 15);
      final testDateString = '${testDate.year}-${testDate.month}-${testDate.day}';
      expect(testDateString, '2024-1-15');
    });
  });

  group('Task Management Integration Tests', () {
    test('Routine task integration with everyday tasks', () {
      // Create sample tasks
      final everydayTask = Task(
        id: 1,
        title: 'Buy groceries',
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      final routineTask = Task(
        id: 2,
        title: 'Morning exercise',
        isRoutine: true,
        createdAt: DateTime.now(),
      );

      // Simulate combining tasks for everyday display
      final everydayTasks = [everydayTask];
      final routineTasks = [routineTask];
      final combinedTasks = [...everydayTasks, ...routineTasks];

      expect(combinedTasks.length, 2);
      expect(combinedTasks.any((task) => task.isRoutine), true);
      expect(combinedTasks.any((task) => !task.isRoutine), true);
    });

    test('Task filtering by type', () {
      final tasks = [
        Task(id: 1, title: 'Everyday Task 1', isRoutine: false, createdAt: DateTime.now()),
        Task(id: 2, title: 'Routine Task 1', isRoutine: true, createdAt: DateTime.now()),
        Task(id: 3, title: 'Everyday Task 2', isRoutine: false, createdAt: DateTime.now()),
        Task(id: 4, title: 'Routine Task 2', isRoutine: true, createdAt: DateTime.now()),
      ];

      final everydayTasks = tasks.where((task) => !task.isRoutine).toList();
      final routineTasks = tasks.where((task) => task.isRoutine).toList();

      expect(everydayTasks.length, 2);
      expect(routineTasks.length, 2);
      expect(everydayTasks.every((task) => !task.isRoutine), true);
      expect(routineTasks.every((task) => task.isRoutine), true);
    });

    test('Task completion status tracking', () {
      final tasks = [
        Task(id: 1, title: 'Task 1', isCompleted: false, createdAt: DateTime.now()),
        Task(id: 2, title: 'Task 2', isCompleted: true, createdAt: DateTime.now()),
        Task(id: 3, title: 'Task 3', isCompleted: false, createdAt: DateTime.now()),
      ];

      final completedTasks = tasks.where((task) => task.isCompleted).toList();
      final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();

      expect(completedTasks.length, 1);
      expect(incompleteTasks.length, 2);
    });

    test('Task validation logic', () {
      // Test valid task
      final validTask = Task(
        title: 'Valid Task',
        createdAt: DateTime.now(),
      );
      expect(validTask.title.isNotEmpty, true);

      // Test task with empty description
      final taskWithEmptyDescription = Task(
        title: 'Task with empty description',
        description: '',
        createdAt: DateTime.now(),
      );
      expect(taskWithEmptyDescription.description, '');

      // Test task with null description
      final taskWithNullDescription = Task(
        title: 'Task with null description',
        description: null,
        createdAt: DateTime.now(),
      );
      expect(taskWithNullDescription.description, isNull);
    });
  });
}