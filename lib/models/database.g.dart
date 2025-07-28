// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRoutineMeta =
      const VerificationMeta('isRoutine');
  @override
  late final GeneratedColumn<bool> isRoutine = GeneratedColumn<bool>(
      'is_routine', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_routine" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _routineTaskIdMeta =
      const VerificationMeta('routineTaskId');
  @override
  late final GeneratedColumn<int> routineTaskId = GeneratedColumn<int>(
      'routine_task_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taskDateMeta =
      const VerificationMeta('taskDate');
  @override
  late final GeneratedColumn<DateTime> taskDate = GeneratedColumn<DateTime>(
      'task_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        isCompleted,
        isRoutine,
        createdAt,
        completedAt,
        routineTaskId,
        taskDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_routine')) {
      context.handle(_isRoutineMeta,
          isRoutine.isAcceptableOrUnknown(data['is_routine']!, _isRoutineMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('routine_task_id')) {
      context.handle(
          _routineTaskIdMeta,
          routineTaskId.isAcceptableOrUnknown(
              data['routine_task_id']!, _routineTaskIdMeta));
    }
    if (data.containsKey('task_date')) {
      context.handle(_taskDateMeta,
          taskDate.isAcceptableOrUnknown(data['task_date']!, _taskDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isRoutine: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_routine'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      routineTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}routine_task_id']),
      taskDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}task_date']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  /// Primary key - auto-incrementing integer ID
  final int id;

  /// Task title - required, non-empty string with length constraints
  final String title;

  /// Optional task description - can be null for simple tasks
  final String? description;

  /// Completion status - defaults to false for new tasks
  final bool isCompleted;

  /// Routine task flag - defaults to false for regular tasks
  final bool isRoutine;

  /// Creation timestamp - required for all tasks
  final DateTime createdAt;

  /// Completion timestamp - null until task is completed
  final DateTime? completedAt;

  /// Reference to routine task ID if this is a daily instance of a routine task
  final int? routineTaskId;

  /// Date for which this task instance is created (for routine task instances)
  final DateTime? taskDate;
  const TaskData(
      {required this.id,
      required this.title,
      this.description,
      required this.isCompleted,
      required this.isRoutine,
      required this.createdAt,
      this.completedAt,
      this.routineTaskId,
      this.taskDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_routine'] = Variable<bool>(isRoutine);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || routineTaskId != null) {
      map['routine_task_id'] = Variable<int>(routineTaskId);
    }
    if (!nullToAbsent || taskDate != null) {
      map['task_date'] = Variable<DateTime>(taskDate);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isCompleted: Value(isCompleted),
      isRoutine: Value(isRoutine),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      routineTaskId: routineTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineTaskId),
      taskDate: taskDate == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDate),
    );
  }

  factory TaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isRoutine: serializer.fromJson<bool>(json['isRoutine']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      routineTaskId: serializer.fromJson<int?>(json['routineTaskId']),
      taskDate: serializer.fromJson<DateTime?>(json['taskDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isRoutine': serializer.toJson<bool>(isRoutine),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'routineTaskId': serializer.toJson<int?>(routineTaskId),
      'taskDate': serializer.toJson<DateTime?>(taskDate),
    };
  }

  TaskData copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          bool? isCompleted,
          bool? isRoutine,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> routineTaskId = const Value.absent(),
          Value<DateTime?> taskDate = const Value.absent()}) =>
      TaskData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        isRoutine: isRoutine ?? this.isRoutine,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        routineTaskId:
            routineTaskId.present ? routineTaskId.value : this.routineTaskId,
        taskDate: taskDate.present ? taskDate.value : this.taskDate,
      );
  TaskData copyWithCompanion(TasksCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isRoutine: data.isRoutine.present ? data.isRoutine.value : this.isRoutine,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      routineTaskId: data.routineTaskId.present
          ? data.routineTaskId.value
          : this.routineTaskId,
      taskDate: data.taskDate.present ? data.taskDate.value : this.taskDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRoutine: $isRoutine, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('routineTaskId: $routineTaskId, ')
          ..write('taskDate: $taskDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, isCompleted,
      isRoutine, createdAt, completedAt, routineTaskId, taskDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isCompleted == this.isCompleted &&
          other.isRoutine == this.isRoutine &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.routineTaskId == this.routineTaskId &&
          other.taskDate == this.taskDate);
}

class TasksCompanion extends UpdateCompanion<TaskData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isCompleted;
  final Value<bool> isRoutine;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> routineTaskId;
  final Value<DateTime?> taskDate;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isRoutine = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.routineTaskId = const Value.absent(),
    this.taskDate = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isRoutine = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.routineTaskId = const Value.absent(),
    this.taskDate = const Value.absent(),
  })  : title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<TaskData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isCompleted,
    Expression<bool>? isRoutine,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? routineTaskId,
    Expression<DateTime>? taskDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isRoutine != null) 'is_routine': isRoutine,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (routineTaskId != null) 'routine_task_id': routineTaskId,
      if (taskDate != null) 'task_date': taskDate,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<bool>? isCompleted,
      Value<bool>? isRoutine,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int?>? routineTaskId,
      Value<DateTime?>? taskDate}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isRoutine: isRoutine ?? this.isRoutine,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      routineTaskId: routineTaskId ?? this.routineTaskId,
      taskDate: taskDate ?? this.taskDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isRoutine.present) {
      map['is_routine'] = Variable<bool>(isRoutine.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (routineTaskId.present) {
      map['routine_task_id'] = Variable<int>(routineTaskId.value);
    }
    if (taskDate.present) {
      map['task_date'] = Variable<DateTime>(taskDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRoutine: $isRoutine, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('routineTaskId: $routineTaskId, ')
          ..write('taskDate: $taskDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<bool> isRoutine,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int?> routineTaskId,
  Value<DateTime?> taskDate,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<bool> isRoutine,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> routineTaskId,
  Value<DateTime?> taskDate,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRoutine => $composableBuilder(
      column: $table.isRoutine, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routineTaskId => $composableBuilder(
      column: $table.routineTaskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get taskDate => $composableBuilder(
      column: $table.taskDate, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRoutine => $composableBuilder(
      column: $table.isRoutine, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routineTaskId => $composableBuilder(
      column: $table.routineTaskId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get taskDate => $composableBuilder(
      column: $table.taskDate, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isRoutine =>
      $composableBuilder(column: $table.isRoutine, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get routineTaskId => $composableBuilder(
      column: $table.routineTaskId, builder: (column) => column);

  GeneratedColumn<DateTime> get taskDate =>
      $composableBuilder(column: $table.taskDate, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, BaseReferences<_$AppDatabase, $TasksTable, TaskData>),
    TaskData,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRoutine = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> routineTaskId = const Value.absent(),
            Value<DateTime?> taskDate = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            isCompleted: isCompleted,
            isRoutine: isRoutine,
            createdAt: createdAt,
            completedAt: completedAt,
            routineTaskId: routineTaskId,
            taskDate: taskDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRoutine = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> routineTaskId = const Value.absent(),
            Value<DateTime?> taskDate = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            isCompleted: isCompleted,
            isRoutine: isRoutine,
            createdAt: createdAt,
            completedAt: completedAt,
            routineTaskId: routineTaskId,
            taskDate: taskDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, BaseReferences<_$AppDatabase, $TasksTable, TaskData>),
    TaskData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
