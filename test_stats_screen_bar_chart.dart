import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/screens/stats_screen.dart';
import 'lib/models/task.dart';
import 'lib/providers/providers.dart';
import 'lib/utils/theme.dart';

/// Simple test to verify the stats screen bar chart implementation
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Mock some tasks for testing
        allTasksProvider.overrideWith((ref) => Future.value([
          Task(
            id: 1,
            title: 'Test Task 1',
            isCompleted: true,
            createdAt: DateTime.now(),
            completedAt: DateTime.now(),
            isRoutine: false,
            priority: TaskPriority.medium,
          ),
          Task(
            id: 2,
            title: 'Test Task 2',
            isCompleted: false,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            isRoutine: false,
            priority: TaskPriority.high,
          ),
          Task(
            id: 3,
            title: 'Test Task 3',
            isCompleted: true,
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
            completedAt: DateTime.now().subtract(const Duration(days: 60)),
            isRoutine: true,
            priority: TaskPriority.none,
          ),
        ])),
      ],
      child: MaterialApp(
        title: 'Stats Screen Bar Chart Test',
        theme: AppTheme.darkTheme,
        home: const StatsScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}