import 'package:uuid/uuid.dart';

/// Base class for all entities with common functionality
/// Reduces code duplication across all entity classes
abstract class BaseEntity {
  String get id;
  DateTime get createdAt;

  /// Get a copy of this entity with optional field overrides
  /// Subclasses must implement this to return their own type
  BaseEntity copyWithBase({
    String? id,
    DateTime? createdAt,
  });

  /// Convert entity to JSON map
  Map<String, dynamic> toJson();

  /// Create entity from JSON map
  /// Subclasses must implement this
  static T fromJson<T extends BaseEntity>(Map<String, dynamic> json, T Function(Map<String, dynamic>) factory) {
    return factory(json);
  }
}

/// Mixin providing UUID generation functionality
mixin UuidMixin {
  static const _uuid = Uuid();

  String generateId() => _uuid.v4();

  String getOrGenerateId(String? existingId) => existingId ?? _uuid.v4();
}

/// Mixin providing timestamp functionality
mixin TimestampMixin {
  DateTime getCurrentTimestamp() => DateTime.now().toUtc();
}

/// Extension for common JSON operations
extension BaseEntityJsonExtension on Map<String, dynamic> {
  String getString(String key, {String defaultValue = ''}) {
    return this[key] as String? ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return this[key] as int? ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    if (this[key] == null) return defaultValue;
    if (this[key] is num) return (this[key] as num).toDouble();
    return double.tryParse(this[key].toString()) ?? defaultValue;
  }

  DateTime getDateTime(String key) {
    if (this[key] == null) return DateTime.now().toUtc();
    return DateTime.parse(this[key] as String);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return this[key] as bool? ?? defaultValue;
  }
}
