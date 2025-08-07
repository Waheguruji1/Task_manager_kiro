import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart' hide Table, Column;
import 'achievement.dart';

// Import the generated code
part 'database.g.dart';

/// Tasks table definition for Drift database
/// 
/// Defines the structure and constraints for storing task data
/// with proper data types and validation rules.
@DataClassName('TaskData')
class Tasks extends Table {
  /// Primary key - auto-incrementing integer ID
  IntColumn get id => integer().autoIncrement()();
  
  /// Task title - required, non-empty string with length constraints
  TextColumn get title => text().withLength(min: 1, max: 255)();
  
  /// Optional task description - can be null for simple tasks
  TextColumn get description => text().nullable()();
  
  /// Completion status - defaults to false for new tasks
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  
  /// Routine task flag - defaults to false for regular tasks
  BoolColumn get isRoutine => boolean().withDefault(const Constant(false))();
  
  /// Creation timestamp - required for all tasks
  DateTimeColumn get createdAt => dateTime()();
  
  /// Completion timestamp - null until task is completed
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  /// Reference to routine task ID if this is a daily instance of a routine task
  IntColumn get routineTaskId => integer().nullable()();
  
  /// Date for which this task instance is created (for routine task instances)
  DateTimeColumn get taskDate => dateTime().nullable()();
  
  /// Priority level of the task - defaults to 0 (none)
  IntColumn get priority => integer().withDefault(const Constant(0))();
  
  /// Scheduled notification time for the task - null if no notification set
  DateTimeColumn get notificationTime => dateTime().nullable()();
  
  /// Unique identifier for the scheduled notification - null if no notification set
  IntColumn get notificationId => integer().nullable()();
}

/// Achievements table definition for Drift database
/// 
/// Defines the structure and constraints for storing achievement data
/// with proper data types and validation rules.
@DataClassName('AchievementData')
class Achievements extends Table {
  /// Primary key - achievement ID as string
  TextColumn get id => text()();
  
  /// Achievement title - required, non-empty string with length constraints
  TextColumn get title => text().withLength(min: 1, max: 255)();
  
  /// Achievement description - required description text
  TextColumn get description => text()();
  
  /// Icon code point for MaterialIcons
  IntColumn get iconCodePoint => integer()();
  
  /// Achievement type as integer enum value
  IntColumn get type => intEnum<AchievementType>()();
  
  /// Target value required to earn this achievement
  IntColumn get targetValue => integer()();
  
  /// Whether this achievement has been earned - defaults to false
  BoolColumn get isEarned => boolean().withDefault(const Constant(false))();
  
  /// Timestamp when achievement was earned - null until earned
  DateTimeColumn get earnedAt => dateTime().nullable()();
  
  /// Current progress towards earning this achievement - defaults to 0
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Main database class for the Task Manager app
/// 
/// Provides type-safe database operations using Drift ORM
/// with proper connection management and query methods.
@DriftDatabase(tables: [Tasks, Achievements])
class AppDatabase extends _$AppDatabase {
  /// Creates database instance with proper connection
  AppDatabase() : super(_openConnection());

  /// Database schema version for migrations
  @override
  int get schemaVersion => 4;

  /// Database migration logic and index creation
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Create indexes for better query performance
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_is_routine 
          ON tasks (is_routine);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_is_completed 
          ON tasks (is_completed);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_created_at 
          ON tasks (created_at);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_completed_at 
          ON tasks (completed_at);
        ''');
        
        // Composite index for routine task queries
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_routine_completed 
          ON tasks (is_routine, is_completed);
        ''');
        
        // Index for text search on title
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_title 
          ON tasks (title);
        ''');
        
        // Index for routine task ID references
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_routine_task_id 
          ON tasks (routine_task_id);
        ''');
        
        // Index for task date
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_task_date 
          ON tasks (task_date);
        ''');
        
        // Index for priority-based queries
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_priority 
          ON tasks (priority);
        ''');
        
        // Index for notification time queries
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_notification_time 
          ON tasks (notification_time);
        ''');
        
        // Index for notification ID queries
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_notification_id 
          ON tasks (notification_id);
        ''');
        
        // Composite index for priority-based sorting with completion status
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_tasks_priority_completed 
          ON tasks (priority, is_completed);
        ''');
        
        // Create indexes for achievements table
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_achievements_is_earned 
          ON achievements (is_earned);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_achievements_type 
          ON achievements (type);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_achievements_earned_at 
          ON achievements (earned_at);
        ''');
        
        // Initialize default achievements
        await _initializeDefaultAchievements();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema upgrades
        if (from < 2) {
          // Add new columns for routine task management
          await customStatement('''
            ALTER TABLE tasks ADD COLUMN routine_task_id INTEGER;
          ''');
          
          await customStatement('''
            ALTER TABLE tasks ADD COLUMN task_date INTEGER;
          ''');
          
          // Add indexes for new columns
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_routine_task_id 
            ON tasks (routine_task_id);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_task_date 
            ON tasks (task_date);
          ''');
        }
        
        if (from < 3) {
          // Add achievements table
          await m.createTable(achievements);
          
          // Create indexes for achievements table
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_achievements_is_earned 
            ON achievements (is_earned);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_achievements_type 
            ON achievements (type);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_achievements_earned_at 
            ON achievements (earned_at);
          ''');
          
          // Initialize default achievements
          await _initializeDefaultAchievements();
        }
        
        if (from < 4) {
          // Add priority and notification columns to tasks table
          await customStatement('''
            ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0;
          ''');
          
          await customStatement('''
            ALTER TABLE tasks ADD COLUMN notification_time INTEGER;
          ''');
          
          await customStatement('''
            ALTER TABLE tasks ADD COLUMN notification_id INTEGER;
          ''');
          
          // Add indexes for new priority and notification columns
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_priority 
            ON tasks (priority);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_notification_time 
            ON tasks (notification_time);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_notification_id 
            ON tasks (notification_id);
          ''');
          
          // Composite index for priority-based sorting with completion status
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_priority_completed 
            ON tasks (priority, is_completed);
          ''');
        }
      },
    );
  }

  // ==================== TASK CRUD OPERATIONS ====================

  /// Retrieves all tasks from the database
  /// 
  /// Returns a list of all tasks ordered by creation date (newest first)
  Future<List<TaskData>> getAllTasks() {
    return (select(tasks)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves all everyday (non-routine) tasks
  /// 
  /// Returns tasks that are not marked as routine, ordered by creation date
  Future<List<TaskData>> getEverydayTasks() {
    return (select(tasks)
      ..where((t) => t.isRoutine.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves all everyday (non-routine) tasks sorted by priority
  /// 
  /// Returns tasks that are not marked as routine, ordered by priority (High → Medium → None) then by creation date
  Future<List<TaskData>> getEverydayTasksSortedByPriority() {
    return (select(tasks)
      ..where((t) => t.isRoutine.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc), // Higher priority values first
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves tasks by priority level
  /// 
  /// [priority] The priority level to filter by (0 = none, 1 = medium, 2 = high)
  /// Returns tasks with the specified priority level
  Future<List<TaskData>> getTasksByPriority(int priority) {
    return (select(tasks)
      ..where((t) => t.priority.equals(priority))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves tasks with scheduled notifications
  /// 
  /// Returns tasks that have notification times set, ordered by notification time
  Future<List<TaskData>> getTasksWithNotifications() {
    return (select(tasks)
      ..where((t) => t.notificationTime.isNotNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.notificationTime, mode: OrderingMode.asc)
      ])).get();
  }

  /// Retrieves tasks with notifications scheduled for a specific date
  /// 
  /// [date] The date to filter notifications by
  /// Returns tasks with notifications scheduled for the specified date
  Future<List<TaskData>> getTasksWithNotificationsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(tasks)
      ..where((t) => t.notificationTime.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([
        (t) => OrderingTerm(expression: t.notificationTime, mode: OrderingMode.asc)
      ])).get();
  }

  /// Retrieves a task by its notification ID
  /// 
  /// [notificationId] The notification ID to search for
  /// Returns the task with the specified notification ID, or null if not found
  Future<TaskData?> getTaskByNotificationId(int notificationId) {
    return (select(tasks)..where((t) => t.notificationId.equals(notificationId))).getSingleOrNull();
  }

  /// Retrieves all routine tasks
  /// 
  /// Returns tasks that are marked as routine, ordered by creation date
  Future<List<TaskData>> getRoutineTasks() {
    return (select(tasks)
      ..where((t) => t.isRoutine.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves tasks created on a specific date
  /// 
  /// [date] The date to filter tasks by
  /// Returns tasks created on the specified date
  Future<List<TaskData>> getTasksForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(tasks)
      ..where((t) => t.createdAt.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves completed tasks
  /// 
  /// Returns all tasks that have been marked as completed
  Future<List<TaskData>> getCompletedTasks() {
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves pending (incomplete) tasks
  /// 
  /// Returns all tasks that have not been completed yet
  Future<List<TaskData>> getPendingTasks() {
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Inserts a new task into the database
  /// 
  /// [task] The task data to insert
  /// Returns the ID of the newly inserted task
  Future<int> insertTask(TasksCompanion task) {
    return into(tasks).insert(task);
  }

  /// Updates an existing task in the database
  /// 
  /// [task] The task data with updated values
  /// Returns true if the update was successful
  Future<bool> updateTask(TasksCompanion task) {
    return update(tasks).replace(task);
  }

  /// Deletes a task from the database
  /// 
  /// [id] The ID of the task to delete
  /// Returns the number of rows affected (should be 1 for successful deletion)
  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Toggles the completion status of a task
  /// 
  /// [id] The ID of the task to toggle
  /// [isCompleted] The new completion status
  /// Returns the number of rows affected
  Future<int> toggleTaskCompletion(int id, bool isCompleted) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(isCompleted),
        completedAt: Value(isCompleted ? DateTime.now() : null),
      ),
    );
  }

  // ==================== ROUTINE TASK OPERATIONS ====================

  /// Resets completion status for all routine tasks
  /// 
  /// This should be called daily to reset routine tasks for the new day
  /// Returns the number of routine tasks that were reset
  Future<int> resetDailyRoutineTasks() async {
    // Use transaction for better performance and data consistency
    return await transaction(() async {
      return (update(tasks)..where((t) => t.isRoutine.equals(true))).write(
        const TasksCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );
    });
  }

  /// Gets routine tasks that should appear in today's everyday tasks
  /// 
  /// Returns routine tasks with their current completion status
  Future<List<TaskData>> getTodaysRoutineTasks() {
    return (select(tasks)
      ..where((t) => t.isRoutine.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)
      ])).get();
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Gets the total count of tasks
  Future<int> getTaskCount() async {
    final countQuery = selectOnly(tasks)..addColumns([tasks.id.count()]);
    final result = await countQuery.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Gets the count of completed tasks
  Future<int> getCompletedTaskCount() async {
    final countQuery = selectOnly(tasks)
      ..addColumns([tasks.id.count()])
      ..where(tasks.isCompleted.equals(true));
    final result = await countQuery.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Gets the count of routine tasks
  Future<int> getRoutineTaskCount() async {
    final countQuery = selectOnly(tasks)
      ..addColumns([tasks.id.count()])
      ..where(tasks.isRoutine.equals(true));
    final result = await countQuery.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Searches tasks by title or description
  /// 
  /// [query] The search term to look for
  /// Returns tasks that contain the query in title or description
  Future<List<TaskData>> searchTasks(String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(tasks)
      ..where((t) => 
        t.title.lower().like(searchTerm) | 
        t.description.lower().like(searchTerm))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Inserts multiple tasks in a single transaction for better performance
  /// 
  /// [taskList] List of tasks to insert
  /// Returns list of inserted task IDs
  Future<List<int>> insertTasksBatch(List<TasksCompanion> taskList) async {
    return await transaction(() async {
      final List<int> insertedIds = [];
      for (final task in taskList) {
        final id = await into(tasks).insert(task);
        insertedIds.add(id);
      }
      return insertedIds;
    });
  }

  /// Updates multiple tasks in a single transaction
  /// 
  /// [taskList] List of tasks to update
  /// Returns true if all updates were successful
  Future<bool> updateTasksBatch(List<TasksCompanion> taskList) async {
    return await transaction(() async {
      for (final task in taskList) {
        final success = await update(tasks).replace(task);
        if (!success) return false;
      }
      return true;
    });
  }

  /// Deletes multiple tasks in a single transaction
  /// 
  /// [taskIds] List of task IDs to delete
  /// Returns the total number of deleted tasks
  Future<int> deleteTasksBatch(List<int> taskIds) async {
    return await transaction(() async {
      int totalDeleted = 0;
      for (final id in taskIds) {
        final deleted = await (delete(tasks)..where((t) => t.id.equals(id))).go();
        totalDeleted += deleted;
      }
      return totalDeleted;
    });
  }

  /// Marks multiple tasks as completed in a single transaction
  /// 
  /// [taskIds] List of task IDs to mark as completed
  /// Returns the number of tasks that were updated
  Future<int> markTasksCompletedBatch(List<int> taskIds) async {
    return await transaction(() async {
      int totalUpdated = 0;
      final now = DateTime.now();
      for (final id in taskIds) {
        final updated = await (update(tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            isCompleted: const Value(true),
            completedAt: Value(now),
          ),
        );
        totalUpdated += updated;
      }
      return totalUpdated;
    });
  }

  // ==================== ACHIEVEMENT CRUD OPERATIONS ====================

  /// Retrieves all achievements from the database
  /// 
  /// Returns a list of all achievements ordered by earned status and title
  Future<List<AchievementData>> getAllAchievements() {
    return (select(achievements)
      ..orderBy([
        (a) => OrderingTerm(expression: a.isEarned, mode: OrderingMode.desc),
        (a) => OrderingTerm(expression: a.title, mode: OrderingMode.asc)
      ])).get();
  }

  /// Retrieves all earned achievements
  /// 
  /// Returns achievements that have been earned, ordered by earned date
  Future<List<AchievementData>> getEarnedAchievements() {
    return (select(achievements)
      ..where((a) => a.isEarned.equals(true))
      ..orderBy([
        (a) => OrderingTerm(expression: a.earnedAt, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves all unearned achievements
  /// 
  /// Returns achievements that have not been earned yet, ordered by progress
  Future<List<AchievementData>> getUnearnedAchievements() {
    return (select(achievements)
      ..where((a) => a.isEarned.equals(false))
      ..orderBy([
        (a) => OrderingTerm(expression: a.currentProgress, mode: OrderingMode.desc),
        (a) => OrderingTerm(expression: a.title, mode: OrderingMode.asc)
      ])).get();
  }

  /// Retrieves achievements by type
  /// 
  /// [type] The achievement type to filter by
  /// Returns achievements of the specified type
  Future<List<AchievementData>> getAchievementsByType(AchievementType type) {
    return (select(achievements)
      ..where((a) => a.type.equals(type.index))
      ..orderBy([
        (a) => OrderingTerm(expression: a.isEarned, mode: OrderingMode.desc),
        (a) => OrderingTerm(expression: a.currentProgress, mode: OrderingMode.desc)
      ])).get();
  }

  /// Retrieves a specific achievement by ID
  /// 
  /// [id] The achievement ID to look for
  /// Returns the achievement if found, null otherwise
  Future<AchievementData?> getAchievementById(String id) {
    return (select(achievements)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new achievement into the database
  /// 
  /// [achievement] The achievement data to insert
  /// Returns the number of rows affected (should be 1 for successful insertion)
  Future<int> insertAchievement(AchievementsCompanion achievement) {
    return into(achievements).insert(achievement);
  }

  /// Updates an existing achievement in the database
  /// 
  /// [achievement] The achievement data with updated values
  /// Returns true if the update was successful
  Future<bool> updateAchievement(AchievementsCompanion achievement) {
    return update(achievements).replace(achievement);
  }

  /// Updates achievement progress
  /// 
  /// [id] The achievement ID to update
  /// [progress] The new progress value
  /// Returns the number of rows affected
  Future<int> updateAchievementProgress(String id, int progress) {
    return (update(achievements)..where((a) => a.id.equals(id))).write(
      AchievementsCompanion(
        currentProgress: Value(progress),
      ),
    );
  }

  /// Marks an achievement as earned
  /// 
  /// [id] The achievement ID to mark as earned
  /// Returns the number of rows affected
  Future<int> earnAchievement(String id) {
    final now = DateTime.now();
    return (update(achievements)..where((a) => a.id.equals(id))).write(
      AchievementsCompanion(
        isEarned: const Value(true),
        earnedAt: Value(now),
      ),
    );
  }

  /// Deletes an achievement from the database
  /// 
  /// [id] The ID of the achievement to delete
  /// Returns the number of rows affected (should be 1 for successful deletion)
  Future<int> deleteAchievement(String id) {
    return (delete(achievements)..where((a) => a.id.equals(id))).go();
  }

  /// Gets the count of earned achievements
  Future<int> getEarnedAchievementCount() async {
    final countQuery = selectOnly(achievements)
      ..addColumns([achievements.id.count()])
      ..where(achievements.isEarned.equals(true));
    final result = await countQuery.getSingle();
    return result.read(achievements.id.count()) ?? 0;
  }

  /// Gets the total count of achievements
  Future<int> getTotalAchievementCount() async {
    final countQuery = selectOnly(achievements)..addColumns([achievements.id.count()]);
    final result = await countQuery.getSingle();
    return result.read(achievements.id.count()) ?? 0;
  }

  /// Resets all achievement progress (useful for testing or data reset)
  /// 
  /// Returns the number of achievements that were reset
  Future<int> resetAllAchievements() async {
    return await transaction(() async {
      return (update(achievements)).write(
        const AchievementsCompanion(
          isEarned: Value(false),
          earnedAt: Value(null),
          currentProgress: Value(0),
        ),
      );
    });
  }

  /// Initialize default achievements in the database
  /// 
  /// This method creates the standard set of achievements that users can earn
  /// based on their task completion behavior and patterns.
  Future<void> _initializeDefaultAchievements() async {
    final defaultAchievements = [
      AchievementsCompanion.insert(
        id: 'first_task',
        title: 'First Task',
        description: 'Complete your first task',
        iconCodePoint: Icons.star.codePoint,
        type: AchievementType.firstTime,
        targetValue: 1,
      ),
      AchievementsCompanion.insert(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Complete tasks for 7 consecutive days',
        iconCodePoint: Icons.local_fire_department.codePoint,
        type: AchievementType.streak,
        targetValue: 7,
      ),
      AchievementsCompanion.insert(
        id: 'month_master',
        title: 'Month Master',
        description: 'Complete tasks for 30 consecutive days',
        iconCodePoint: Icons.emoji_events.codePoint,
        type: AchievementType.streak,
        targetValue: 30,
      ),
      AchievementsCompanion.insert(
        id: 'routine_champion',
        title: 'Routine Champion',
        description: 'Complete all routine tasks for 7 consecutive days',
        iconCodePoint: Icons.repeat.codePoint,
        type: AchievementType.routineConsistency,
        targetValue: 7,
      ),
      AchievementsCompanion.insert(
        id: 'task_tornado',
        title: 'Task Tornado',
        description: 'Complete 20 tasks in a single day',
        iconCodePoint: Icons.flash_on.codePoint,
        type: AchievementType.dailyCompletion,
        targetValue: 20,
      ),
      AchievementsCompanion.insert(
        id: 'daily_achiever',
        title: 'Daily Achiever',
        description: 'Complete 5 tasks in a single day',
        iconCodePoint: Icons.check_circle.codePoint,
        type: AchievementType.dailyCompletion,
        targetValue: 5,
      ),
      AchievementsCompanion.insert(
        id: 'super_achiever',
        title: 'Super Achiever',
        description: 'Complete 10 tasks in a single day',
        iconCodePoint: Icons.stars.codePoint,
        type: AchievementType.dailyCompletion,
        targetValue: 10,
      ),
      AchievementsCompanion.insert(
        id: 'consistency_king',
        title: 'Consistency King',
        description: 'Complete tasks for 14 consecutive days',
        iconCodePoint: Icons.trending_up.codePoint,
        type: AchievementType.streak,
        targetValue: 14,
      ),
    ];

    // Insert achievements, updating if they already exist
    for (final achievement in defaultAchievements) {
      try {
        await into(achievements).insertOnConflictUpdate(achievement);
      } catch (e) {
        // If insertOnConflictUpdate is not available, try individual insert
        final existing = await getAchievementById(achievement.id.value);
        if (existing == null) {
          await into(achievements).insert(achievement);
        }
      }
    }
  }
}

/// Opens a connection to the SQLite database
/// 
/// Creates the database file in the app's documents directory
/// with proper configuration for the platform.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Get the app's documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'task_manager.db'));
    
    // Create the database connection
    return NativeDatabase.createInBackground(file);
  });
}