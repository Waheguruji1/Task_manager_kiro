import 'dart:ui';
import '../models/task.dart';

/// Service for calculating statistics and heatmap data for task visualization
class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  /// Calculate completion heatmap data with daily task completion counts
  /// Returns a map where keys are normalized dates and values are completion counts
  Map<DateTime, int> calculateCompletionHeatmapData(List<Task> tasks) {
    final Map<DateTime, int> heatmapData = {};
    
    // Filter completed tasks only
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    
    // Group tasks by completion date
    for (final task in completedTasks) {
      if (task.completedAt != null) {
        final normalizedDate = _normalizeDate(task.completedAt!);
        heatmapData[normalizedDate] = (heatmapData[normalizedDate] ?? 0) + 1;
      }
    }
    
    return heatmapData;
  }

  /// Calculate creation vs completion heatmap data with both metrics per day
  /// Returns a map where keys are dates and values contain 'created' and 'completed' counts
  Map<DateTime, Map<String, int>> calculateCreationCompletionHeatmapData(List<Task> tasks) {
    final Map<DateTime, Map<String, int>> heatmapData = {};
    
    // Process task creation dates
    for (final task in tasks) {
      final createdDate = _normalizeDate(task.createdAt);
      heatmapData[createdDate] ??= {'created': 0, 'completed': 0};
      heatmapData[createdDate]!['created'] = heatmapData[createdDate]!['created']! + 1;
    }
    
    // Process task completion dates
    for (final task in tasks.where((t) => t.isCompleted && t.completedAt != null)) {
      final completedDate = _normalizeDate(task.completedAt!);
      heatmapData[completedDate] ??= {'created': 0, 'completed': 0};
      heatmapData[completedDate]!['completed'] = heatmapData[completedDate]!['completed']! + 1;
    }
    
    return heatmapData;
  }

  /// Calculate overall statistics for all tasks
  Map<String, dynamic> calculateOverallStats(List<Task> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final routineTasks = tasks.where((task) => task.isRoutine).length;
    final everydayTasks = tasks.where((task) => !task.isRoutine).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    
    // Calculate current streak
    final currentStreak = _calculateCurrentStreak(tasks);
    
    // Calculate average daily completions
    final completionData = calculateCompletionHeatmapData(tasks);
    final avgDailyCompletions = completionData.isNotEmpty 
        ? (completionData.values.reduce((a, b) => a + b) / completionData.length).round()
        : 0;
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'routineTasks': routineTasks,
      'everydayTasks': everydayTasks,
      'completionRate': completionRate,
      'currentStreak': currentStreak,
      'avgDailyCompletions': avgDailyCompletions,
    };
  }

  /// Calculate monthly statistics for a specific month
  Map<String, int> calculateMonthlyStats(List<Task> tasks, DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    
    final monthTasks = tasks.where((task) {
      return task.createdAt.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             task.createdAt.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();
    
    final completedInMonth = monthTasks.where((task) => 
        task.isCompleted && 
        task.completedAt != null &&
        task.completedAt!.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        task.completedAt!.isBefore(monthEnd.add(const Duration(days: 1)))
    ).length;
    
    return {
      'created': monthTasks.length,
      'completed': completedInMonth,
      'routine': monthTasks.where((task) => task.isRoutine).length,
      'everyday': monthTasks.where((task) => !task.isRoutine).length,
    };
  }

  /// Calculate weekly statistics for a specific week
  Map<String, int> calculateWeeklyStats(List<Task> tasks, DateTime week) {
    final weekStart = week.subtract(Duration(days: week.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekTasks = tasks.where((task) {
      return task.createdAt.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             task.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    final completedInWeek = weekTasks.where((task) => 
        task.isCompleted && 
        task.completedAt != null &&
        task.completedAt!.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        task.completedAt!.isBefore(weekEnd.add(const Duration(days: 1)))
    ).length;
    
    return {
      'created': weekTasks.length,
      'completed': completedInWeek,
      'routine': weekTasks.where((task) => task.isRoutine).length,
      'everyday': weekTasks.where((task) => !task.isRoutine).length,
    };
  }

  /// Calculate color intensity for heatmap visualization
  /// Returns a color with intensity based on value relative to maxValue
  Color getHeatmapIntensityColor(int value, int maxValue, Color baseColor) {
    if (value == 0 || maxValue == 0) {
      return baseColor.withValues(alpha: 0.1);
    }
    
    final intensity = (value / maxValue).clamp(0.0, 1.0);
    
    // Create intensity levels: 0.2, 0.4, 0.6, 0.8, 1.0
    final level = (intensity * 5).ceil() / 5;
    final opacity = (0.2 + (level * 0.8)).clamp(0.2, 1.0);
    
    return baseColor.withValues(alpha: opacity);
  }

  /// Get date range between start and end dates (inclusive)
  List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);
    
    while (current.isBefore(normalizedEnd) || current.isAtSameMomentAs(normalizedEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  /// Get the current year's date range for heatmap display
  List<DateTime> getCurrentYearDateRange() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year, 12, 31);
    return getDateRange(yearStart, yearEnd);
  }

  /// Calculate the maximum value from heatmap data for intensity scaling
  int getMaxValueFromHeatmapData(Map<DateTime, int> data) {
    return data.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);
  }

  /// Calculate the maximum value from creation/completion heatmap data
  int getMaxValueFromCreationCompletionData(Map<DateTime, Map<String, int>> data) {
    if (data.isEmpty) return 0;
    
    int maxValue = 0;
    for (final dayData in data.values) {
      final total = (dayData['created'] ?? 0) + (dayData['completed'] ?? 0);
      if (total > maxValue) {
        maxValue = total;
      }
    }
    return maxValue;
  }

  /// Normalize date to remove time component (set to midnight)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculate current streak of consecutive days with completed tasks
  int _calculateCurrentStreak(List<Task> tasks) {
    final completionData = calculateCompletionHeatmapData(tasks);
    if (completionData.isEmpty) return 0;
    
    int streak = 0;
    var currentDate = _normalizeDate(DateTime.now());
    
    // Check if today has completions, if not start from yesterday
    if (completionData[currentDate] == null || completionData[currentDate] == 0) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days with completions going backwards
    while (completionData[currentDate] != null && completionData[currentDate]! > 0) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  /// Get monthly breakdown of the current year for heatmap organization
  List<DateTime> getMonthsInCurrentYear() {
    final now = DateTime.now();
    final months = <DateTime>[];
    
    for (int month = 1; month <= 12; month++) {
      months.add(DateTime(now.year, month, 1));
    }
    
    return months;
  }

  /// Calculate productivity score based on completion rate and consistency
  double calculateProductivityScore(List<Task> tasks) {
    final stats = calculateOverallStats(tasks);
    final completionRate = stats['completionRate'] as int;
    final currentStreak = stats['currentStreak'] as int;
    
    // Base score from completion rate (0-70 points)
    final completionScore = (completionRate * 0.7).clamp(0.0, 70.0);
    
    // Streak bonus (0-30 points, capped at 30 days)
    final streakScore = (currentStreak.clamp(0, 30) * 1.0).clamp(0.0, 30.0);
    
    return (completionScore + streakScore).clamp(0.0, 100.0);
  }
}