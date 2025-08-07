import 'package:flutter/material.dart';

/// Priority levels for tasks
enum TaskPriority {
  none,
  medium,
  high,
}

/// Task data model for the task manager app
///
/// Represents a single task with all necessary properties for task management
/// including completion status, routine task identification, timestamps,
/// priority levels, and notification support.
class Task {
  /// Unique identifier for the task (null for new tasks before database insertion)
  final int? id;

  /// Title of the task (required, non-empty)
  final String title;

  /// Optional description providing additional details about the task
  final String? description;

  /// Completion status of the task
  final bool isCompleted;

  /// Whether this task is a routine task that should appear daily
  final bool isRoutine;

  /// Timestamp when the task was created
  final DateTime createdAt;

  /// Timestamp when the task was completed (null if not completed)
  final DateTime? completedAt;

  /// Reference to routine task ID if this is a daily instance of a routine task
  final int? routineTaskId;

  /// Date for which this task instance is created (for routine task instances)
  final DateTime? taskDate;

  /// Priority level of the task
  final TaskPriority priority;

  /// Scheduled notification time for the task
  final DateTime? notificationTime;

  /// Unique identifier for the scheduled notification
  final int? notificationId;

  /// Creates a new Task instance
  ///
  /// [title] is required and cannot be empty
  /// [isCompleted] defaults to false
  /// [isRoutine] defaults to false
  /// [createdAt] is required to track task creation time
  /// [priority] defaults to TaskPriority.none
  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isRoutine = false,
    required this.createdAt,
    this.completedAt,
    this.routineTaskId,
    this.taskDate,
    this.priority = TaskPriority.none,
    this.notificationTime,
    this.notificationId,
  }) : assert(title.trim().isNotEmpty, 'Task title cannot be empty');

  /// Creates a copy of this task with optionally updated values
  ///
  /// This method is essential for immutable state management and updating
  /// task properties without modifying the original instance.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isRoutine,
    DateTime? createdAt,
    DateTime? completedAt,
    int? routineTaskId,
    DateTime? taskDate,
    TaskPriority? priority,
    DateTime? notificationTime,
    int? notificationId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isRoutine: isRoutine ?? this.isRoutine,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      routineTaskId: routineTaskId ?? this.routineTaskId,
      taskDate: taskDate ?? this.taskDate,
      priority: priority ?? this.priority,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  /// Converts the task to a JSON map for serialization
  ///
  /// Used for data persistence and API communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isRoutine': isRoutine,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'routineTaskId': routineTaskId,
      'taskDate': taskDate?.toIso8601String(),
      'priority': priority.index,
      'notificationTime': notificationTime?.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  /// Creates a Task instance from a JSON map
  ///
  /// Used for deserializing data from storage or API responses
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isRoutine: json['isRoutine'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      routineTaskId: json['routineTaskId'] as int?,
      taskDate: json['taskDate'] != null
          ? DateTime.parse(json['taskDate'] as String)
          : null,
      priority: json['priority'] != null
          ? TaskPriority.values[json['priority'] as int]
          : TaskPriority.none,
      notificationTime: json['notificationTime'] != null
          ? DateTime.parse(json['notificationTime'] as String)
          : null,
      notificationId: json['notificationId'] as int?,
    );
  }

  /// String representation of the task for debugging
  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, isRoutine: $isRoutine, createdAt: $createdAt)';
  }

  /// Equality comparison based on all properties
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.isRoutine == isRoutine &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.routineTaskId == routineTaskId &&
        other.taskDate == taskDate &&
        other.priority == priority &&
        other.notificationTime == notificationTime &&
        other.notificationId == notificationId;
  }

  /// Hash code based on all properties
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      isCompleted,
      isRoutine,
      createdAt,
      completedAt,
      routineTaskId,
      taskDate,
      priority,
      notificationTime,
      notificationId,
    );
  }

  /// Helper method to check if task was completed today
  bool get isCompletedToday {
    if (!isCompleted || completedAt == null) return false;

    final now = DateTime.now();
    final completed = completedAt!;

    return now.year == completed.year &&
        now.month == completed.month &&
        now.day == completed.day;
  }

  /// Helper method to get a display-friendly creation date
  String get formattedCreatedDate {
    final now = DateTime.now();
    final created = createdAt;

    if (now.year == created.year &&
        now.month == created.month &&
        now.day == created.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == created.year &&
        yesterday.month == created.month &&
        yesterday.day == created.day) {
      return 'Yesterday';
    }

    return '${created.day}/${created.month}/${created.year}';
  }

  /// Gets the color associated with the task's priority level
  ///
  /// Returns purple for high priority, green for medium priority,
  /// and transparent for no priority
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFF8B5CF6); // Purple
      case TaskPriority.medium:
        return const Color(0xFF10B981); // Green
      case TaskPriority.none:
        return Colors.transparent;
    }
  }

  /// Gets the priority order value for sorting tasks
  ///
  /// Returns 0 for high priority, 1 for medium priority, and 2 for no priority.
  /// Lower values indicate higher priority for sorting purposes.
  int get priorityOrder {
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.none:
        return 2;
    }
  }

  /// Static method to sort a list of tasks by priority
  ///
  /// Sorts tasks in descending priority order (High → Medium → No Priority)
  static List<Task> sortByPriority(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    return sortedTasks;
  }

  /// Gets truncated title for display purposes
  ///
  /// [maxLength] Maximum number of characters to display before truncation
  /// Returns the title truncated with ellipsis if it exceeds maxLength
  String getTruncatedTitle({int maxLength = 50}) {
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength)}...';
  }

  /// Gets truncated description for display purposes
  ///
  /// [maxLength] Maximum number of characters to display before truncation
  /// Returns the description truncated with ellipsis if it exceeds maxLength
  String? getTruncatedDescription({int maxLength = 80}) {
    if (description == null || description!.isEmpty) return null;
    if (description!.length <= maxLength) return description;
    return '${description!.substring(0, maxLength)}...';
  }

  /// Checks if the title needs truncation
  ///
  /// [maxLength] Maximum number of characters before truncation is needed
  bool get isTitleTruncated => title.length > 50;

  /// Checks if the description needs truncation
  ///
  /// [maxLength] Maximum number of characters before truncation is needed
  bool get isDescriptionTruncated => 
      description != null && description!.length > 80;
}
