import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
}

/// Main database class for the Task Manager app
/// 
/// Provides type-safe database operations using Drift ORM
/// with proper connection management and query methods.
@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  /// Creates database instance with proper connection
  AppDatabase() : super(_openConnection());

  /// Database schema version for migrations
  @override
  int get schemaVersion => 1;

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
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future schema upgrades will be handled here
        if (from < 2) {
          // Example: Add indexes if upgrading from version 1
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
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_routine_completed 
            ON tasks (is_routine, is_completed);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_tasks_title 
            ON tasks (title);
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