import 'dart:convert';

/// Utility class for BodyPart related operations
/// Provides common functions for parsing and handling body part data
class BodyPartUtils {
  BodyPartUtils._();

  /// Parse bodyPartIds JSON array string to List<String>
  /// Handles various formats: JSON array, comma-separated, single value, etc.
  /// Handles NULL, empty, or invalid JSON input
  static List<String> parseBodyPartIds(String? bodyPartIdsJson) {
    // Handle NULL or empty values
    if (bodyPartIdsJson == null || bodyPartIdsJson.isEmpty || bodyPartIdsJson == '[]') {
      return [];
    }
    try {
      // First try JSON array format: ["body_back", "body_glutes"]
      final decoded = jsonDecode(bodyPartIdsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      // If it's a string but not a JSON array, try comma-separated format
      if (decoded is String) {
        return parseBodyPartIds(decoded);
      }
      return [];
    } catch (e) {
      // If JSON parsing fails, try comma-separated format: "body_back,body_glutes"
      if (bodyPartIdsJson.contains(',')) {
        return bodyPartIdsJson.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      // Try single value: "body_back"
      return [bodyPartIdsJson.trim()];
    }
  }

  /// Convert a List<String> to JSON array string for database storage
  static String bodyPartIdsToJson(List<String> bodyPartIds) {
    return jsonEncode(bodyPartIds);
  }

  /// Check if a body part ID list is empty or null
  static bool isEmpty(String? bodyPartIdsJson) {
    return parseBodyPartIds(bodyPartIdsJson).isEmpty;
  }

  /// Get the primary (first) body part ID from the list
  static String? getPrimaryBodyPartId(String? bodyPartIdsJson) {
    final ids = parseBodyPartIds(bodyPartIdsJson);
    return ids.isNotEmpty ? ids.first : null;
  }
}
