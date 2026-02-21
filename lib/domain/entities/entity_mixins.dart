import 'base_entity.dart';

/// Mixin providing common toJson functionality for entities
/// Reduces code duplication in entity classes
mixin EntityJsonMixin<T> on BaseEntity {
  /// Additional fields to include in JSON beyond id and createdAt
  Map<String, dynamic> additionalJson();

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    ...additionalJson(),
  };
}

/// Mixin providing common copyWith functionality for entities
mixin EntityCopyWithMixin<T> {
  /// Create a copy with optional field overrides
  T copyWith({
    String? id,
    DateTime? createdAt,
  });
}

/// Extension to simplify JSON parsing for entities
extension EntityJsonParser on Map<String, dynamic> {
  /// Parse a string or return default
  String parseString(String key, {String defaultValue = ''}) {
    return this[key] as String? ?? defaultValue;
  }

  /// Parse an int or return default
  int parseInt(String key, {int defaultValue = 0}) {
    return this[key] as int? ?? defaultValue;
  }

  /// Parse a double or return default
  double parseDouble(String key, {double defaultValue = 0.0}) {
    if (this[key] == null) return defaultValue;
    if (this[key] is num) return (this[key] as num).toDouble();
    return double.tryParse(this[key].toString()) ?? defaultValue;
  }

  /// Parse a DateTime or return now
  DateTime parseDateTime(String key) {
    if (this[key] == null) return DateTime.now().toUtc();
    return DateTime.parse(this[key] as String);
  }

  /// Parse a bool or return default
  bool parseBool(String key, {bool defaultValue = false}) {
    return this[key] as bool? ?? defaultValue;
  }
}
