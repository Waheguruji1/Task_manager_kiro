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
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notificationTimeMeta =
      const VerificationMeta('notificationTime');
  @override
  late final GeneratedColumn<DateTime> notificationTime =
      GeneratedColumn<DateTime>('notification_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
        taskDate,
        priority,
        notificationTime,
        notificationId
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
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('notification_time')) {
      context.handle(
          _notificationTimeMeta,
          notificationTime.isAcceptableOrUnknown(
              data['notification_time']!, _notificationTimeMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
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
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      notificationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}notification_time']),
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id']),
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

  /// Priority level of the task - defaults to 0 (none)
  final int priority;

  /// Scheduled notification time for the task - null if no notification set
  final DateTime? notificationTime;

  /// Unique identifier for the scheduled notification - null if no notification set
  final int? notificationId;
  const TaskData(
      {required this.id,
      required this.title,
      this.description,
      required this.isCompleted,
      required this.isRoutine,
      required this.createdAt,
      this.completedAt,
      this.routineTaskId,
      this.taskDate,
      required this.priority,
      this.notificationTime,
      this.notificationId});
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
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || notificationTime != null) {
      map['notification_time'] = Variable<DateTime>(notificationTime);
    }
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
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
      priority: Value(priority),
      notificationTime: notificationTime == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationTime),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
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
      priority: serializer.fromJson<int>(json['priority']),
      notificationTime:
          serializer.fromJson<DateTime?>(json['notificationTime']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
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
      'priority': serializer.toJson<int>(priority),
      'notificationTime': serializer.toJson<DateTime?>(notificationTime),
      'notificationId': serializer.toJson<int?>(notificationId),
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
          Value<DateTime?> taskDate = const Value.absent(),
          int? priority,
          Value<DateTime?> notificationTime = const Value.absent(),
          Value<int?> notificationId = const Value.absent()}) =>
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
        priority: priority ?? this.priority,
        notificationTime: notificationTime.present
            ? notificationTime.value
            : this.notificationTime,
        notificationId:
            notificationId.present ? notificationId.value : this.notificationId,
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
      priority: data.priority.present ? data.priority.value : this.priority,
      notificationTime: data.notificationTime.present
          ? data.notificationTime.value
          : this.notificationTime,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
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
          ..write('taskDate: $taskDate, ')
          ..write('priority: $priority, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      notificationId);
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
          other.taskDate == this.taskDate &&
          other.priority == this.priority &&
          other.notificationTime == this.notificationTime &&
          other.notificationId == this.notificationId);
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
  final Value<int> priority;
  final Value<DateTime?> notificationTime;
  final Value<int?> notificationId;
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
    this.priority = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.notificationId = const Value.absent(),
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
    this.priority = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.notificationId = const Value.absent(),
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
    Expression<int>? priority,
    Expression<DateTime>? notificationTime,
    Expression<int>? notificationId,
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
      if (priority != null) 'priority': priority,
      if (notificationTime != null) 'notification_time': notificationTime,
      if (notificationId != null) 'notification_id': notificationId,
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
      Value<DateTime?>? taskDate,
      Value<int>? priority,
      Value<DateTime?>? notificationTime,
      Value<int?>? notificationId}) {
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
      priority: priority ?? this.priority,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationId: notificationId ?? this.notificationId,
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
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (notificationTime.present) {
      map['notification_time'] = Variable<DateTime>(notificationTime.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
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
          ..write('taskDate: $taskDate, ')
          ..write('priority: $priority, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AchievementType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AchievementType>($AchievementsTable.$convertertype);
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
      'target_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isEarnedMeta =
      const VerificationMeta('isEarned');
  @override
  late final GeneratedColumn<bool> isEarned = GeneratedColumn<bool>(
      'is_earned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_earned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _earnedAtMeta =
      const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
      'earned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _currentProgressMeta =
      const VerificationMeta('currentProgress');
  @override
  late final GeneratedColumn<int> currentProgress = GeneratedColumn<int>(
      'current_progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        iconCodePoint,
        type,
        targetValue,
        isEarned,
        earnedAt,
        currentProgress
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<AchievementData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('is_earned')) {
      context.handle(_isEarnedMeta,
          isEarned.isAcceptableOrUnknown(data['is_earned']!, _isEarnedMeta));
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta,
          earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    }
    if (data.containsKey('current_progress')) {
      context.handle(
          _currentProgressMeta,
          currentProgress.isAcceptableOrUnknown(
              data['current_progress']!, _currentProgressMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      type: $AchievementsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_value'])!,
      isEarned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_earned'])!,
      earnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}earned_at']),
      currentProgress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_progress'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AchievementType, int, int> $convertertype =
      const EnumIndexConverter<AchievementType>(AchievementType.values);
}

class AchievementData extends DataClass implements Insertable<AchievementData> {
  /// Primary key - achievement ID as string
  final String id;

  /// Achievement title - required, non-empty string with length constraints
  final String title;

  /// Achievement description - required description text
  final String description;

  /// Icon code point for MaterialIcons
  final int iconCodePoint;

  /// Achievement type as integer enum value
  final AchievementType type;

  /// Target value required to earn this achievement
  final int targetValue;

  /// Whether this achievement has been earned - defaults to false
  final bool isEarned;

  /// Timestamp when achievement was earned - null until earned
  final DateTime? earnedAt;

  /// Current progress towards earning this achievement - defaults to 0
  final int currentProgress;
  const AchievementData(
      {required this.id,
      required this.title,
      required this.description,
      required this.iconCodePoint,
      required this.type,
      required this.targetValue,
      required this.isEarned,
      this.earnedAt,
      required this.currentProgress});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    {
      map['type'] =
          Variable<int>($AchievementsTable.$convertertype.toSql(type));
    }
    map['target_value'] = Variable<int>(targetValue);
    map['is_earned'] = Variable<bool>(isEarned);
    if (!nullToAbsent || earnedAt != null) {
      map['earned_at'] = Variable<DateTime>(earnedAt);
    }
    map['current_progress'] = Variable<int>(currentProgress);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      iconCodePoint: Value(iconCodePoint),
      type: Value(type),
      targetValue: Value(targetValue),
      isEarned: Value(isEarned),
      earnedAt: earnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(earnedAt),
      currentProgress: Value(currentProgress),
    );
  }

  factory AchievementData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      type: $AchievementsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      targetValue: serializer.fromJson<int>(json['targetValue']),
      isEarned: serializer.fromJson<bool>(json['isEarned']),
      earnedAt: serializer.fromJson<DateTime?>(json['earnedAt']),
      currentProgress: serializer.fromJson<int>(json['currentProgress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'type': serializer
          .toJson<int>($AchievementsTable.$convertertype.toJson(type)),
      'targetValue': serializer.toJson<int>(targetValue),
      'isEarned': serializer.toJson<bool>(isEarned),
      'earnedAt': serializer.toJson<DateTime?>(earnedAt),
      'currentProgress': serializer.toJson<int>(currentProgress),
    };
  }

  AchievementData copyWith(
          {String? id,
          String? title,
          String? description,
          int? iconCodePoint,
          AchievementType? type,
          int? targetValue,
          bool? isEarned,
          Value<DateTime?> earnedAt = const Value.absent(),
          int? currentProgress}) =>
      AchievementData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        type: type ?? this.type,
        targetValue: targetValue ?? this.targetValue,
        isEarned: isEarned ?? this.isEarned,
        earnedAt: earnedAt.present ? earnedAt.value : this.earnedAt,
        currentProgress: currentProgress ?? this.currentProgress,
      );
  AchievementData copyWithCompanion(AchievementsCompanion data) {
    return AchievementData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      type: data.type.present ? data.type.value : this.type,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      isEarned: data.isEarned.present ? data.isEarned.value : this.isEarned,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      currentProgress: data.currentProgress.present
          ? data.currentProgress.value
          : this.currentProgress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('isEarned: $isEarned, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('currentProgress: $currentProgress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, iconCodePoint, type,
      targetValue, isEarned, earnedAt, currentProgress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconCodePoint == this.iconCodePoint &&
          other.type == this.type &&
          other.targetValue == this.targetValue &&
          other.isEarned == this.isEarned &&
          other.earnedAt == this.earnedAt &&
          other.currentProgress == this.currentProgress);
}

class AchievementsCompanion extends UpdateCompanion<AchievementData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> iconCodePoint;
  final Value<AchievementType> type;
  final Value<int> targetValue;
  final Value<bool> isEarned;
  final Value<DateTime?> earnedAt;
  final Value<int> currentProgress;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.type = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.isEarned = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.currentProgress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required int iconCodePoint,
    required AchievementType type,
    required int targetValue,
    this.isEarned = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.currentProgress = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        iconCodePoint = Value(iconCodePoint),
        type = Value(type),
        targetValue = Value(targetValue);
  static Insertable<AchievementData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? iconCodePoint,
    Expression<int>? type,
    Expression<int>? targetValue,
    Expression<bool>? isEarned,
    Expression<DateTime>? earnedAt,
    Expression<int>? currentProgress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (type != null) 'type': type,
      if (targetValue != null) 'target_value': targetValue,
      if (isEarned != null) 'is_earned': isEarned,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (currentProgress != null) 'current_progress': currentProgress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<int>? iconCodePoint,
      Value<AchievementType>? type,
      Value<int>? targetValue,
      Value<bool>? isEarned,
      Value<DateTime?>? earnedAt,
      Value<int>? currentProgress,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($AchievementsTable.$convertertype.toSql(type.value));
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (isEarned.present) {
      map['is_earned'] = Variable<bool>(isEarned.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (currentProgress.present) {
      map['current_progress'] = Variable<int>(currentProgress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('isEarned: $isEarned, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('currentProgress: $currentProgress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks, achievements];
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
  Value<int> priority,
  Value<DateTime?> notificationTime,
  Value<int?> notificationId,
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
  Value<int> priority,
  Value<DateTime?> notificationTime,
  Value<int?> notificationId,
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

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get notificationTime => $composableBuilder(
      column: $table.notificationTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get notificationTime => $composableBuilder(
      column: $table.notificationTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get notificationTime => $composableBuilder(
      column: $table.notificationTime, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);
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
            Value<int> priority = const Value.absent(),
            Value<DateTime?> notificationTime = const Value.absent(),
            Value<int?> notificationId = const Value.absent(),
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
            priority: priority,
            notificationTime: notificationTime,
            notificationId: notificationId,
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
            Value<int> priority = const Value.absent(),
            Value<DateTime?> notificationTime = const Value.absent(),
            Value<int?> notificationId = const Value.absent(),
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
            priority: priority,
            notificationTime: notificationTime,
            notificationId: notificationId,
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
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  required String title,
  required String description,
  required int iconCodePoint,
  required AchievementType type,
  required int targetValue,
  Value<bool> isEarned,
  Value<DateTime?> earnedAt,
  Value<int> currentProgress,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> iconCodePoint,
  Value<AchievementType> type,
  Value<int> targetValue,
  Value<bool> isEarned,
  Value<DateTime?> earnedAt,
  Value<int> currentProgress,
  Value<int> rowid,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AchievementType, AchievementType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEarned => $composableBuilder(
      column: $table.isEarned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentProgress => $composableBuilder(
      column: $table.currentProgress,
      builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEarned => $composableBuilder(
      column: $table.isEarned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentProgress => $composableBuilder(
      column: $table.currentProgress,
      builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AchievementType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<bool> get isEarned =>
      $composableBuilder(column: $table.isEarned, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<int> get currentProgress => $composableBuilder(
      column: $table.currentProgress, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    AchievementData,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementData,
      BaseReferences<_$AppDatabase, $AchievementsTable, AchievementData>
    ),
    AchievementData,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<AchievementType> type = const Value.absent(),
            Value<int> targetValue = const Value.absent(),
            Value<bool> isEarned = const Value.absent(),
            Value<DateTime?> earnedAt = const Value.absent(),
            Value<int> currentProgress = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            title: title,
            description: description,
            iconCodePoint: iconCodePoint,
            type: type,
            targetValue: targetValue,
            isEarned: isEarned,
            earnedAt: earnedAt,
            currentProgress: currentProgress,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required int iconCodePoint,
            required AchievementType type,
            required int targetValue,
            Value<bool> isEarned = const Value.absent(),
            Value<DateTime?> earnedAt = const Value.absent(),
            Value<int> currentProgress = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            title: title,
            description: description,
            iconCodePoint: iconCodePoint,
            type: type,
            targetValue: targetValue,
            isEarned: isEarned,
            earnedAt: earnedAt,
            currentProgress: currentProgress,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    AchievementData,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementData,
      BaseReferences<_$AppDatabase, $AchievementsTable, AchievementData>
    ),
    AchievementData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
}
