// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BodyPartsTable extends BodyParts
    with TableInfo<$BodyPartsTable, BodyPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyPart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyPart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $BodyPartsTable createAlias(String alias) {
    return $BodyPartsTable(attachedDatabase, alias);
  }
}

class BodyPart extends DataClass implements Insertable<BodyPart> {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isDeleted;
  const BodyPart({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  BodyPartsCompanion toCompanion(bool nullToAbsent) {
    return BodyPartsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory BodyPart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyPart(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  BodyPart copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isDeleted,
  }) => BodyPart(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  BodyPart copyWithCompanion(BodyPartsCompanion data) {
    return BodyPart(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyPart(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyPart &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class BodyPartsCompanion extends UpdateCompanion<BodyPart> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const BodyPartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyPartsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<BodyPart> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyPartsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return BodyPartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyPartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartIdsMeta = const VerificationMeta(
    'bodyPartIds',
  );
  @override
  late final GeneratedColumn<String> bodyPartIds = GeneratedColumn<String>(
    'body_part_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, bodyPartIds, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body_part_ids')) {
      context.handle(
        _bodyPartIdsMeta,
        bodyPartIds.isAcceptableOrUnknown(
          data['body_part_ids']!,
          _bodyPartIdsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bodyPartIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part_ids'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String name;
  final String bodyPartIds;
  final DateTime createdAt;
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPartIds,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['body_part_ids'] = Variable<String>(bodyPartIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      bodyPartIds: Value(bodyPartIds),
      createdAt: Value(createdAt),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bodyPartIds: serializer.fromJson<String>(json['bodyPartIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bodyPartIds': serializer.toJson<String>(bodyPartIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? bodyPartIds,
    DateTime? createdAt,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    bodyPartIds: bodyPartIds ?? this.bodyPartIds,
    createdAt: createdAt ?? this.createdAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bodyPartIds: data.bodyPartIds.present
          ? data.bodyPartIds.value
          : this.bodyPartIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyPartIds: $bodyPartIds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, bodyPartIds, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.bodyPartIds == this.bodyPartIds &&
          other.createdAt == this.createdAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bodyPartIds;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bodyPartIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    this.bodyPartIds = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bodyPartIds,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bodyPartIds != null) 'body_part_ids': bodyPartIds,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bodyPartIds,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bodyPartIds.present) {
      map['body_part_ids'] = Variable<String>(bodyPartIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyPartIds: $bodyPartIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartIdsMeta = const VerificationMeta(
    'bodyPartIds',
  );
  @override
  late final GeneratedColumn<String> bodyPartIds = GeneratedColumn<String>(
    'body_part_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, startTime, createdAt, bodyPartIds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('body_part_ids')) {
      context.handle(
        _bodyPartIdsMeta,
        bodyPartIds.isAcceptableOrUnknown(
          data['body_part_ids']!,
          _bodyPartIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      bodyPartIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part_ids'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final DateTime startTime;
  final DateTime createdAt;
  final String bodyPartIds;
  const WorkoutSession({
    required this.id,
    required this.startTime,
    required this.createdAt,
    required this.bodyPartIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['body_part_ids'] = Variable<String>(bodyPartIds);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      createdAt: Value(createdAt),
      bodyPartIds: Value(bodyPartIds),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      bodyPartIds: serializer.fromJson<String>(json['bodyPartIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'bodyPartIds': serializer.toJson<String>(bodyPartIds),
    };
  }

  WorkoutSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? createdAt,
    String? bodyPartIds,
  }) => WorkoutSession(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    createdAt: createdAt ?? this.createdAt,
    bodyPartIds: bodyPartIds ?? this.bodyPartIds,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      bodyPartIds: data.bodyPartIds.present
          ? data.bodyPartIds.value
          : this.bodyPartIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('bodyPartIds: $bodyPartIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startTime, createdAt, bodyPartIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.createdAt == this.createdAt &&
          other.bodyPartIds == this.bodyPartIds);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<DateTime> startTime;
  final Value<DateTime> createdAt;
  final Value<String> bodyPartIds;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.bodyPartIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required DateTime startTime,
    required DateTime createdAt,
    this.bodyPartIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime),
       createdAt = Value(createdAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? createdAt,
    Expression<String>? bodyPartIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (createdAt != null) 'created_at': createdAt,
      if (bodyPartIds != null) 'body_part_ids': bodyPartIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startTime,
    Value<DateTime>? createdAt,
    Value<String>? bodyPartIds,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (bodyPartIds.present) {
      map['body_part_ids'] = Variable<String>(bodyPartIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('bodyPartIds: $bodyPartIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseRecordsTable extends ExerciseRecords
    with TableInfo<$ExerciseRecordsTable, ExerciseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, exerciseId, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $ExerciseRecordsTable createAlias(String alias) {
    return $ExerciseRecordsTable(attachedDatabase, alias);
  }
}

class ExerciseRecord extends DataClass implements Insertable<ExerciseRecord> {
  final String id;
  final String sessionId;
  final String? exerciseId;
  final bool isDeleted;
  const ExerciseRecord({
    required this.id,
    required this.sessionId,
    this.exerciseId,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ExerciseRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      isDeleted: Value(isDeleted),
    );
  }

  factory ExerciseRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRecord(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ExerciseRecord copyWith({
    String? id,
    String? sessionId,
    Value<String?> exerciseId = const Value.absent(),
    bool? isDeleted,
  }) => ExerciseRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  ExerciseRecord copyWithCompanion(ExerciseRecordsCompanion data) {
    return ExerciseRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, exerciseId, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.isDeleted == this.isDeleted);
}

class ExerciseRecordsCompanion extends UpdateCompanion<ExerciseRecord> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> exerciseId;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ExerciseRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseRecordsCompanion.insert({
    required String id,
    required String sessionId,
    this.exerciseId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId);
  static Insertable<ExerciseRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? exerciseId,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return ExerciseRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetRecordsTable extends SetRecords
    with TableInfo<$SetRecordsTable, SetRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseRecordIdMeta = const VerificationMeta(
    'exerciseRecordId',
  );
  @override
  late final GeneratedColumn<String> exerciseRecordId = GeneratedColumn<String>(
    'exercise_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_records (id)',
    ),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseRecordId,
    weight,
    reps,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_record_id')) {
      context.handle(
        _exerciseRecordIdMeta,
        exerciseRecordId.isAcceptableOrUnknown(
          data['exercise_record_id']!,
          _exerciseRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseRecordIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_record_id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $SetRecordsTable createAlias(String alias) {
    return $SetRecordsTable(attachedDatabase, alias);
  }
}

class SetRecord extends DataClass implements Insertable<SetRecord> {
  final String id;
  final String exerciseRecordId;
  final double weight;
  final int reps;
  final int orderIndex;
  const SetRecord({
    required this.id,
    required this.exerciseRecordId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_record_id'] = Variable<String>(exerciseRecordId);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  SetRecordsCompanion toCompanion(bool nullToAbsent) {
    return SetRecordsCompanion(
      id: Value(id),
      exerciseRecordId: Value(exerciseRecordId),
      weight: Value(weight),
      reps: Value(reps),
      orderIndex: Value(orderIndex),
    );
  }

  factory SetRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetRecord(
      id: serializer.fromJson<String>(json['id']),
      exerciseRecordId: serializer.fromJson<String>(json['exerciseRecordId']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseRecordId': serializer.toJson<String>(exerciseRecordId),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  SetRecord copyWith({
    String? id,
    String? exerciseRecordId,
    double? weight,
    int? reps,
    int? orderIndex,
  }) => SetRecord(
    id: id ?? this.id,
    exerciseRecordId: exerciseRecordId ?? this.exerciseRecordId,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  SetRecord copyWithCompanion(SetRecordsCompanion data) {
    return SetRecord(
      id: data.id.present ? data.id.value : this.id,
      exerciseRecordId: data.exerciseRecordId.present
          ? data.exerciseRecordId.value
          : this.exerciseRecordId,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetRecord(')
          ..write('id: $id, ')
          ..write('exerciseRecordId: $exerciseRecordId, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseRecordId, weight, reps, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetRecord &&
          other.id == this.id &&
          other.exerciseRecordId == this.exerciseRecordId &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.orderIndex == this.orderIndex);
}

class SetRecordsCompanion extends UpdateCompanion<SetRecord> {
  final Value<String> id;
  final Value<String> exerciseRecordId;
  final Value<double> weight;
  final Value<int> reps;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const SetRecordsCompanion({
    this.id = const Value.absent(),
    this.exerciseRecordId = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetRecordsCompanion.insert({
    required String id,
    required String exerciseRecordId,
    required double weight,
    required int reps,
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseRecordId = Value(exerciseRecordId),
       weight = Value(weight),
       reps = Value(reps),
       orderIndex = Value(orderIndex);
  static Insertable<SetRecord> custom({
    Expression<String>? id,
    Expression<String>? exerciseRecordId,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseRecordId != null) 'exercise_record_id': exerciseRecordId,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseRecordId,
    Value<double>? weight,
    Value<int>? reps,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return SetRecordsCompanion(
      id: id ?? this.id,
      exerciseRecordId: exerciseRecordId ?? this.exerciseRecordId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseRecordId.present) {
      map['exercise_record_id'] = Variable<String>(exerciseRecordId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetRecordsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseRecordId: $exerciseRecordId, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingPlansTable extends TrainingPlans
    with TableInfo<$TrainingPlansTable, TrainingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleLengthDaysMeta = const VerificationMeta(
    'cycleLengthDays',
  );
  @override
  late final GeneratedColumn<int> cycleLengthDays = GeneratedColumn<int>(
    'cycle_length_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentDayIndexMeta = const VerificationMeta(
    'currentDayIndex',
  );
  @override
  late final GeneratedColumn<int> currentDayIndex = GeneratedColumn<int>(
    'current_day_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cycleLengthDays,
    createdAt,
    isActive,
    currentDayIndex,
    startDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cycle_length_days')) {
      context.handle(
        _cycleLengthDaysMeta,
        cycleLengthDays.isAcceptableOrUnknown(
          data['cycle_length_days']!,
          _cycleLengthDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleLengthDaysMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('current_day_index')) {
      context.handle(
        _currentDayIndexMeta,
        currentDayIndex.isAcceptableOrUnknown(
          data['current_day_index']!,
          _currentDayIndexMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cycleLengthDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length_days'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      currentDayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_day_index'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
    );
  }

  @override
  $TrainingPlansTable createAlias(String alias) {
    return $TrainingPlansTable(attachedDatabase, alias);
  }
}

class TrainingPlan extends DataClass implements Insertable<TrainingPlan> {
  final String id;
  final String name;
  final int cycleLengthDays;
  final DateTime createdAt;
  final bool isActive;
  final int? currentDayIndex;
  final DateTime? startDate;
  const TrainingPlan({
    required this.id,
    required this.name,
    required this.cycleLengthDays,
    required this.createdAt,
    required this.isActive,
    this.currentDayIndex,
    this.startDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['cycle_length_days'] = Variable<int>(cycleLengthDays);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || currentDayIndex != null) {
      map['current_day_index'] = Variable<int>(currentDayIndex);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    return map;
  }

  TrainingPlansCompanion toCompanion(bool nullToAbsent) {
    return TrainingPlansCompanion(
      id: Value(id),
      name: Value(name),
      cycleLengthDays: Value(cycleLengthDays),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
      currentDayIndex: currentDayIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(currentDayIndex),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
    );
  }

  factory TrainingPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingPlan(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cycleLengthDays: serializer.fromJson<int>(json['cycleLengthDays']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      currentDayIndex: serializer.fromJson<int?>(json['currentDayIndex']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cycleLengthDays': serializer.toJson<int>(cycleLengthDays),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
      'currentDayIndex': serializer.toJson<int?>(currentDayIndex),
      'startDate': serializer.toJson<DateTime?>(startDate),
    };
  }

  TrainingPlan copyWith({
    String? id,
    String? name,
    int? cycleLengthDays,
    DateTime? createdAt,
    bool? isActive,
    Value<int?> currentDayIndex = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
  }) => TrainingPlan(
    id: id ?? this.id,
    name: name ?? this.name,
    cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
    createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
    currentDayIndex: currentDayIndex.present
        ? currentDayIndex.value
        : this.currentDayIndex,
    startDate: startDate.present ? startDate.value : this.startDate,
  );
  TrainingPlan copyWithCompanion(TrainingPlansCompanion data) {
    return TrainingPlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cycleLengthDays: data.cycleLengthDays.present
          ? data.cycleLengthDays.value
          : this.cycleLengthDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      currentDayIndex: data.currentDayIndex.present
          ? data.currentDayIndex.value
          : this.currentDayIndex,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cycleLengthDays: $cycleLengthDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('currentDayIndex: $currentDayIndex, ')
          ..write('startDate: $startDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cycleLengthDays,
    createdAt,
    isActive,
    currentDayIndex,
    startDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingPlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.cycleLengthDays == this.cycleLengthDays &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive &&
          other.currentDayIndex == this.currentDayIndex &&
          other.startDate == this.startDate);
}

class TrainingPlansCompanion extends UpdateCompanion<TrainingPlan> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> cycleLengthDays;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<int?> currentDayIndex;
  final Value<DateTime?> startDate;
  final Value<int> rowid;
  const TrainingPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cycleLengthDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.currentDayIndex = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingPlansCompanion.insert({
    required String id,
    required String name,
    required int cycleLengthDays,
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.currentDayIndex = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       cycleLengthDays = Value(cycleLengthDays),
       createdAt = Value(createdAt);
  static Insertable<TrainingPlan> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? cycleLengthDays,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<int>? currentDayIndex,
    Expression<DateTime>? startDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cycleLengthDays != null) 'cycle_length_days': cycleLengthDays,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (currentDayIndex != null) 'current_day_index': currentDayIndex,
      if (startDate != null) 'start_date': startDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? cycleLengthDays,
    Value<DateTime>? createdAt,
    Value<bool>? isActive,
    Value<int?>? currentDayIndex,
    Value<DateTime?>? startDate,
    Value<int>? rowid,
  }) {
    return TrainingPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      startDate: startDate ?? this.startDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cycleLengthDays.present) {
      map['cycle_length_days'] = Variable<int>(cycleLengthDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (currentDayIndex.present) {
      map['current_day_index'] = Variable<int>(currentDayIndex.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cycleLengthDays: $cycleLengthDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('currentDayIndex: $currentDayIndex, ')
          ..write('startDate: $startDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanItemsTable extends PlanItems
    with TableInfo<$PlanItemsTable, PlanItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_plans (id)',
    ),
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartIdsMeta = const VerificationMeta(
    'bodyPartIds',
  );
  @override
  late final GeneratedColumn<String> bodyPartIds = GeneratedColumn<String>(
    'body_part_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, planId, dayIndex, bodyPartIds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('body_part_ids')) {
      context.handle(
        _bodyPartIdsMeta,
        bodyPartIds.isAcceptableOrUnknown(
          data['body_part_ids']!,
          _bodyPartIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyPartIdsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      bodyPartIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part_ids'],
      )!,
    );
  }

  @override
  $PlanItemsTable createAlias(String alias) {
    return $PlanItemsTable(attachedDatabase, alias);
  }
}

class PlanItem extends DataClass implements Insertable<PlanItem> {
  final String id;
  final String planId;
  final int dayIndex;
  final String bodyPartIds;
  const PlanItem({
    required this.id,
    required this.planId,
    required this.dayIndex,
    required this.bodyPartIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['day_index'] = Variable<int>(dayIndex);
    map['body_part_ids'] = Variable<String>(bodyPartIds);
    return map;
  }

  PlanItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanItemsCompanion(
      id: Value(id),
      planId: Value(planId),
      dayIndex: Value(dayIndex),
      bodyPartIds: Value(bodyPartIds),
    );
  }

  factory PlanItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanItem(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      bodyPartIds: serializer.fromJson<String>(json['bodyPartIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'bodyPartIds': serializer.toJson<String>(bodyPartIds),
    };
  }

  PlanItem copyWith({
    String? id,
    String? planId,
    int? dayIndex,
    String? bodyPartIds,
  }) => PlanItem(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    dayIndex: dayIndex ?? this.dayIndex,
    bodyPartIds: bodyPartIds ?? this.bodyPartIds,
  );
  PlanItem copyWithCompanion(PlanItemsCompanion data) {
    return PlanItem(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      bodyPartIds: data.bodyPartIds.present
          ? data.bodyPartIds.value
          : this.bodyPartIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanItem(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('bodyPartIds: $bodyPartIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, dayIndex, bodyPartIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanItem &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.dayIndex == this.dayIndex &&
          other.bodyPartIds == this.bodyPartIds);
}

class PlanItemsCompanion extends UpdateCompanion<PlanItem> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> dayIndex;
  final Value<String> bodyPartIds;
  final Value<int> rowid;
  const PlanItemsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.bodyPartIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanItemsCompanion.insert({
    required String id,
    required String planId,
    required int dayIndex,
    required String bodyPartIds,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       dayIndex = Value(dayIndex),
       bodyPartIds = Value(bodyPartIds);
  static Insertable<PlanItem> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? dayIndex,
    Expression<String>? bodyPartIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (bodyPartIds != null) 'body_part_ids': bodyPartIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? dayIndex,
    Value<String>? bodyPartIds,
    Value<int>? rowid,
  }) {
    return PlanItemsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (bodyPartIds.present) {
      map['body_part_ids'] = Variable<String>(bodyPartIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('bodyPartIds: $bodyPartIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BodyPartsTable bodyParts = $BodyPartsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $ExerciseRecordsTable exerciseRecords = $ExerciseRecordsTable(
    this,
  );
  late final $SetRecordsTable setRecords = $SetRecordsTable(this);
  late final $TrainingPlansTable trainingPlans = $TrainingPlansTable(this);
  late final $PlanItemsTable planItems = $PlanItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bodyParts,
    exercises,
    workoutSessions,
    exerciseRecords,
    setRecords,
    trainingPlans,
    planItems,
  ];
}

typedef $$BodyPartsTableCreateCompanionBuilder =
    BodyPartsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$BodyPartsTableUpdateCompanionBuilder =
    BodyPartsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$BodyPartsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyPartsTable> {
  $$BodyPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyPartsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyPartsTable> {
  $$BodyPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyPartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyPartsTable> {
  $$BodyPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$BodyPartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyPartsTable,
          BodyPart,
          $$BodyPartsTableFilterComposer,
          $$BodyPartsTableOrderingComposer,
          $$BodyPartsTableAnnotationComposer,
          $$BodyPartsTableCreateCompanionBuilder,
          $$BodyPartsTableUpdateCompanionBuilder,
          (BodyPart, BaseReferences<_$AppDatabase, $BodyPartsTable, BodyPart>),
          BodyPart,
          PrefetchHooks Function()
        > {
  $$BodyPartsTableTableManager(_$AppDatabase db, $BodyPartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyPartsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyPartsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyPartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyPartsTable,
      BodyPart,
      $$BodyPartsTableFilterComposer,
      $$BodyPartsTableOrderingComposer,
      $$BodyPartsTableAnnotationComposer,
      $$BodyPartsTableCreateCompanionBuilder,
      $$BodyPartsTableUpdateCompanionBuilder,
      (BodyPart, BaseReferences<_$AppDatabase, $BodyPartsTable, BodyPart>),
      BodyPart,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      required String name,
      Value<String> bodyPartIds,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bodyPartIds,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseRecordsTable, List<ExerciseRecord>>
  _exerciseRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseRecords,
    aliasName: $_aliasNameGenerator(
      db.exercises.id,
      db.exerciseRecords.exerciseId,
    ),
  );

  $$ExerciseRecordsTableProcessedTableManager get exerciseRecordsRefs {
    final manager = $$ExerciseRecordsTableTableManager(
      $_db,
      $_db.exerciseRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseRecordsRefs(
    Expression<bool> Function($$ExerciseRecordsTableFilterComposer f) f,
  ) {
    final $$ExerciseRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> exerciseRecordsRefs<T extends Object>(
    Expression<T> Function($$ExerciseRecordsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({bool exerciseRecordsRefs})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bodyPartIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                bodyPartIds: bodyPartIds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> bodyPartIds = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                bodyPartIds: bodyPartIds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseRecordsRefs) db.exerciseRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseRecordsRefs)
                    await $_getPrefetchedData<
                      Exercise,
                      $ExercisesTable,
                      ExerciseRecord
                    >(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences
                          ._exerciseRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExercisesTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.exerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({bool exerciseRecordsRefs})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required DateTime startTime,
      required DateTime createdAt,
      Value<String> bodyPartIds,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startTime,
      Value<DateTime> createdAt,
      Value<String> bodyPartIds,
      Value<int> rowid,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExerciseRecordsTable, List<ExerciseRecord>>
  _exerciseRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseRecords,
    aliasName: $_aliasNameGenerator(
      db.workoutSessions.id,
      db.exerciseRecords.sessionId,
    ),
  );

  $$ExerciseRecordsTableProcessedTableManager get exerciseRecordsRefs {
    final manager = $$ExerciseRecordsTableTableManager(
      $_db,
      $_db.exerciseRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseRecordsRefs(
    Expression<bool> Function($$ExerciseRecordsTableFilterComposer f) f,
  ) {
    final $$ExerciseRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => column,
  );

  Expression<T> exerciseRecordsRefs<T extends Object>(
    Expression<T> Function($$ExerciseRecordsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({bool exerciseRecordsRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> bodyPartIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                startTime: startTime,
                createdAt: createdAt,
                bodyPartIds: bodyPartIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startTime,
                required DateTime createdAt,
                Value<String> bodyPartIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                startTime: startTime,
                createdAt: createdAt,
                bodyPartIds: bodyPartIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseRecordsRefs) db.exerciseRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseRecordsRefs)
                    await $_getPrefetchedData<
                      WorkoutSession,
                      $WorkoutSessionsTable,
                      ExerciseRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._exerciseRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({bool exerciseRecordsRefs})
    >;
typedef $$ExerciseRecordsTableCreateCompanionBuilder =
    ExerciseRecordsCompanion Function({
      required String id,
      required String sessionId,
      Value<String?> exerciseId,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$ExerciseRecordsTableUpdateCompanionBuilder =
    ExerciseRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String?> exerciseId,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$ExerciseRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseRecordsTable, ExerciseRecord> {
  $$ExerciseRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.workoutSessions.createAlias(
        $_aliasNameGenerator(
          db.exerciseRecords.sessionId,
          db.workoutSessions.id,
        ),
      );

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.exerciseRecords.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager? get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id');
    if ($_column == null) return null;
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetRecordsTable, List<SetRecord>>
  _setRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setRecords,
    aliasName: $_aliasNameGenerator(
      db.exerciseRecords.id,
      db.setRecords.exerciseRecordId,
    ),
  );

  $$SetRecordsTableProcessedTableManager get setRecordsRefs {
    final manager = $$SetRecordsTableTableManager($_db, $_db.setRecords).filter(
      (f) => f.exerciseRecordId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_setRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseRecordsTable> {
  $$ExerciseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setRecordsRefs(
    Expression<bool> Function($$SetRecordsTableFilterComposer f) f,
  ) {
    final $$SetRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setRecords,
      getReferencedColumn: (t) => t.exerciseRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetRecordsTableFilterComposer(
            $db: $db,
            $table: $db.setRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseRecordsTable> {
  $$ExerciseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseRecordsTable> {
  $$ExerciseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setRecordsRefs<T extends Object>(
    Expression<T> Function($$SetRecordsTableAnnotationComposer a) f,
  ) {
    final $$SetRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setRecords,
      getReferencedColumn: (t) => t.exerciseRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.setRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseRecordsTable,
          ExerciseRecord,
          $$ExerciseRecordsTableFilterComposer,
          $$ExerciseRecordsTableOrderingComposer,
          $$ExerciseRecordsTableAnnotationComposer,
          $$ExerciseRecordsTableCreateCompanionBuilder,
          $$ExerciseRecordsTableUpdateCompanionBuilder,
          (ExerciseRecord, $$ExerciseRecordsTableReferences),
          ExerciseRecord,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool setRecordsRefs,
          })
        > {
  $$ExerciseRecordsTableTableManager(
    _$AppDatabase db,
    $ExerciseRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRecordsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String?> exerciseId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                setRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (setRecordsRefs) db.setRecords],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$ExerciseRecordsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$ExerciseRecordsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$ExerciseRecordsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$ExerciseRecordsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (setRecordsRefs)
                        await $_getPrefetchedData<
                          ExerciseRecord,
                          $ExerciseRecordsTable,
                          SetRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseRecordsTableReferences
                              ._setRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).setRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExerciseRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseRecordsTable,
      ExerciseRecord,
      $$ExerciseRecordsTableFilterComposer,
      $$ExerciseRecordsTableOrderingComposer,
      $$ExerciseRecordsTableAnnotationComposer,
      $$ExerciseRecordsTableCreateCompanionBuilder,
      $$ExerciseRecordsTableUpdateCompanionBuilder,
      (ExerciseRecord, $$ExerciseRecordsTableReferences),
      ExerciseRecord,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool setRecordsRefs,
      })
    >;
typedef $$SetRecordsTableCreateCompanionBuilder =
    SetRecordsCompanion Function({
      required String id,
      required String exerciseRecordId,
      required double weight,
      required int reps,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$SetRecordsTableUpdateCompanionBuilder =
    SetRecordsCompanion Function({
      Value<String> id,
      Value<String> exerciseRecordId,
      Value<double> weight,
      Value<int> reps,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$SetRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SetRecordsTable, SetRecord> {
  $$SetRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseRecordsTable _exerciseRecordIdTable(_$AppDatabase db) =>
      db.exerciseRecords.createAlias(
        $_aliasNameGenerator(
          db.setRecords.exerciseRecordId,
          db.exerciseRecords.id,
        ),
      );

  $$ExerciseRecordsTableProcessedTableManager get exerciseRecordId {
    final $_column = $_itemColumn<String>('exercise_record_id')!;

    final manager = $$ExerciseRecordsTableTableManager(
      $_db,
      $_db.exerciseRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseRecordsTableFilterComposer get exerciseRecordId {
    final $$ExerciseRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRecordId,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseRecordsTableOrderingComposer get exerciseRecordId {
    final $$ExerciseRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRecordId,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$ExerciseRecordsTableAnnotationComposer get exerciseRecordId {
    final $$ExerciseRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRecordId,
      referencedTable: $db.exerciseRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetRecordsTable,
          SetRecord,
          $$SetRecordsTableFilterComposer,
          $$SetRecordsTableOrderingComposer,
          $$SetRecordsTableAnnotationComposer,
          $$SetRecordsTableCreateCompanionBuilder,
          $$SetRecordsTableUpdateCompanionBuilder,
          (SetRecord, $$SetRecordsTableReferences),
          SetRecord,
          PrefetchHooks Function({bool exerciseRecordId})
        > {
  $$SetRecordsTableTableManager(_$AppDatabase db, $SetRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseRecordId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetRecordsCompanion(
                id: id,
                exerciseRecordId: exerciseRecordId,
                weight: weight,
                reps: reps,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseRecordId,
                required double weight,
                required int reps,
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => SetRecordsCompanion.insert(
                id: id,
                exerciseRecordId: exerciseRecordId,
                weight: weight,
                reps: reps,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseRecordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseRecordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseRecordId,
                                referencedTable: $$SetRecordsTableReferences
                                    ._exerciseRecordIdTable(db),
                                referencedColumn: $$SetRecordsTableReferences
                                    ._exerciseRecordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetRecordsTable,
      SetRecord,
      $$SetRecordsTableFilterComposer,
      $$SetRecordsTableOrderingComposer,
      $$SetRecordsTableAnnotationComposer,
      $$SetRecordsTableCreateCompanionBuilder,
      $$SetRecordsTableUpdateCompanionBuilder,
      (SetRecord, $$SetRecordsTableReferences),
      SetRecord,
      PrefetchHooks Function({bool exerciseRecordId})
    >;
typedef $$TrainingPlansTableCreateCompanionBuilder =
    TrainingPlansCompanion Function({
      required String id,
      required String name,
      required int cycleLengthDays,
      required DateTime createdAt,
      Value<bool> isActive,
      Value<int?> currentDayIndex,
      Value<DateTime?> startDate,
      Value<int> rowid,
    });
typedef $$TrainingPlansTableUpdateCompanionBuilder =
    TrainingPlansCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> cycleLengthDays,
      Value<DateTime> createdAt,
      Value<bool> isActive,
      Value<int?> currentDayIndex,
      Value<DateTime?> startDate,
      Value<int> rowid,
    });

final class $$TrainingPlansTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingPlansTable, TrainingPlan> {
  $$TrainingPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItem>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: $_aliasNameGenerator(db.trainingPlans.id, db.planItems.planId),
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingPlansTable,
          TrainingPlan,
          $$TrainingPlansTableFilterComposer,
          $$TrainingPlansTableOrderingComposer,
          $$TrainingPlansTableAnnotationComposer,
          $$TrainingPlansTableCreateCompanionBuilder,
          $$TrainingPlansTableUpdateCompanionBuilder,
          (TrainingPlan, $$TrainingPlansTableReferences),
          TrainingPlan,
          PrefetchHooks Function({bool planItemsRefs})
        > {
  $$TrainingPlansTableTableManager(_$AppDatabase db, $TrainingPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cycleLengthDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> currentDayIndex = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingPlansCompanion(
                id: id,
                name: name,
                cycleLengthDays: cycleLengthDays,
                createdAt: createdAt,
                isActive: isActive,
                currentDayIndex: currentDayIndex,
                startDate: startDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int cycleLengthDays,
                required DateTime createdAt,
                Value<bool> isActive = const Value.absent(),
                Value<int?> currentDayIndex = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingPlansCompanion.insert(
                id: id,
                name: name,
                cycleLengthDays: cycleLengthDays,
                createdAt: createdAt,
                isActive: isActive,
                currentDayIndex: currentDayIndex,
                startDate: startDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (planItemsRefs) db.planItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planItemsRefs)
                    await $_getPrefetchedData<
                      TrainingPlan,
                      $TrainingPlansTable,
                      PlanItem
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingPlansTableReferences
                          ._planItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrainingPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).planItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrainingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingPlansTable,
      TrainingPlan,
      $$TrainingPlansTableFilterComposer,
      $$TrainingPlansTableOrderingComposer,
      $$TrainingPlansTableAnnotationComposer,
      $$TrainingPlansTableCreateCompanionBuilder,
      $$TrainingPlansTableUpdateCompanionBuilder,
      (TrainingPlan, $$TrainingPlansTableReferences),
      TrainingPlan,
      PrefetchHooks Function({bool planItemsRefs})
    >;
typedef $$PlanItemsTableCreateCompanionBuilder =
    PlanItemsCompanion Function({
      required String id,
      required String planId,
      required int dayIndex,
      required String bodyPartIds,
      Value<int> rowid,
    });
typedef $$PlanItemsTableUpdateCompanionBuilder =
    PlanItemsCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> dayIndex,
      Value<String> bodyPartIds,
      Value<int> rowid,
    });

final class $$PlanItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItem> {
  $$PlanItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingPlansTable _planIdTable(_$AppDatabase db) =>
      db.trainingPlans.createAlias(
        $_aliasNameGenerator(db.planItems.planId, db.trainingPlans.id),
      );

  $$TrainingPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$TrainingPlansTableTableManager(
      $_db,
      $_db.trainingPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingPlansTableFilterComposer get planId {
    final $$TrainingPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableFilterComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingPlansTableOrderingComposer get planId {
    final $$TrainingPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableOrderingComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get bodyPartIds => $composableBuilder(
    column: $table.bodyPartIds,
    builder: (column) => column,
  );

  $$TrainingPlansTableAnnotationComposer get planId {
    final $$TrainingPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.trainingPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanItemsTable,
          PlanItem,
          $$PlanItemsTableFilterComposer,
          $$PlanItemsTableOrderingComposer,
          $$PlanItemsTableAnnotationComposer,
          $$PlanItemsTableCreateCompanionBuilder,
          $$PlanItemsTableUpdateCompanionBuilder,
          (PlanItem, $$PlanItemsTableReferences),
          PlanItem,
          PrefetchHooks Function({bool planId})
        > {
  $$PlanItemsTableTableManager(_$AppDatabase db, $PlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> bodyPartIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion(
                id: id,
                planId: planId,
                dayIndex: dayIndex,
                bodyPartIds: bodyPartIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int dayIndex,
                required String bodyPartIds,
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion.insert(
                id: id,
                planId: planId,
                dayIndex: dayIndex,
                bodyPartIds: bodyPartIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlanItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$PlanItemsTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$PlanItemsTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanItemsTable,
      PlanItem,
      $$PlanItemsTableFilterComposer,
      $$PlanItemsTableOrderingComposer,
      $$PlanItemsTableAnnotationComposer,
      $$PlanItemsTableCreateCompanionBuilder,
      $$PlanItemsTableUpdateCompanionBuilder,
      (PlanItem, $$PlanItemsTableReferences),
      PlanItem,
      PrefetchHooks Function({bool planId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BodyPartsTableTableManager get bodyParts =>
      $$BodyPartsTableTableManager(_db, _db.bodyParts);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$ExerciseRecordsTableTableManager get exerciseRecords =>
      $$ExerciseRecordsTableTableManager(_db, _db.exerciseRecords);
  $$SetRecordsTableTableManager get setRecords =>
      $$SetRecordsTableTableManager(_db, _db.setRecords);
  $$TrainingPlansTableTableManager get trainingPlans =>
      $$TrainingPlansTableTableManager(_db, _db.trainingPlans);
  $$PlanItemsTableTableManager get planItems =>
      $$PlanItemsTableTableManager(_db, _db.planItems);
}
