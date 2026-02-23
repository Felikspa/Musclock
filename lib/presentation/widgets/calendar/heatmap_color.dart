import 'package:flutter/material.dart';

/// Heatmap color mapping utilities
/// Provides color schemes based on Training Points (TP) confidence levels
class HeatmapColor {
  /// Get heatmap color based on TP value and max TP
  /// Returns gradient colors from light to deep green/gold
  static Color getColor(double tp, double maxTP) {
    if (tp <= 0) return Colors.transparent;
    
    final normalized = (tp / maxTP).clamp(0.0, 1.0);
    
    if (normalized < 0.25) {
      return Colors.green.shade200; // Light green - low activity
    } else if (normalized < 0.5) {
      return Colors.green.shade300; // Medium-light green
    } else if (normalized < 0.75) {
      return Colors.green.shade500; // Medium green
    } else if (normalized < 0.9) {
      return Colors.green.shade700; // Deep green
    } else {
      return Colors.amber.shade600; // Gold - high intensity
    }
  }

  /// Get heatmap color with opacity for different visual effects
  static Color getColorWithOpacity(double tp, double maxTP, {double baseOpacity = 1.0}) {
    final color = getColor(tp, maxTP);
    return color.withOpacity(baseOpacity);
  }

  /// Get color based on confidence level (1: body part only, 2: sets, 3: complete)
  /// This provides visual feedback on data completeness
  static Color getColorByConfidenceLevel(int level, {double intensity = 1.0}) {
    switch (level) {
      case 1:
        // Level 1: Body part only - light green
        return Colors.green.shade200.withOpacity(intensity.clamp(0.0, 1.0));
      case 2:
        // Level 2: Has sets - medium green
        return Colors.green.shade400.withOpacity(intensity.clamp(0.0, 1.0));
      case 3:
        // Level 3: Complete data - deep green/gold
        return Colors.green.shade600.withOpacity(intensity.clamp(0.0, 1.0));
      default:
        return Colors.transparent;
    }
  }

  /// Get text label for confidence level
  static String getConfidenceLabel(int level) {
    switch (level) {
      case 1:
        return '部位记录';
      case 2:
        return '组数记录';
      case 3:
        return '完整记录';
      default:
        return '无记录';
    }
  }

  /// Get English text label for confidence level
  static String getConfidenceLabelEn(int level) {
    switch (level) {
      case 1:
        return 'Body Part Only';
      case 2:
        return 'Sets Recorded';
      case 3:
        return 'Complete';
      default:
        return 'No Data';
    }
  }

  /// Get color for background based on normalized intensity
  static Color getBackgroundColor(double normalizedIntensity) {
    if (normalizedIntensity <= 0) return Colors.transparent;
    
    // Create a gradient from light to deep
    final colors = [
      Colors.green.shade100,
      Colors.green.shade200,
      Colors.green.shade300,
      Colors.green.shade400,
      Colors.green.shade500,
      Colors.green.shade600,
      Colors.green.shade700,
      Colors.amber.shade600,
    ];
    
    final index = ((normalizedIntensity * (colors.length - 1)).round()).clamp(0, colors.length - 1);
    return colors[index];
  }

  /// Get contrasting text color (black or white) based on background
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Legend items for heatmap display
  static List<HeatmapLegendItem> getLegendItems() {
    return [
      HeatmapLegendItem(
        color: Colors.green.shade200,
        label: 'Light',
        description: 'Body part only',
      ),
      HeatmapLegendItem(
        color: Colors.green.shade400,
        label: 'Medium',
        description: 'Sets recorded',
      ),
      HeatmapLegendItem(
        color: Colors.green.shade600,
        label: 'Strong',
        description: 'Complete data',
      ),
      HeatmapLegendItem(
        color: Colors.amber.shade600,
        label: 'Peak',
        description: 'High intensity',
      ),
    ];
  }
}

/// Data class for heatmap legend items
class HeatmapLegendItem {
  final Color color;
  final String label;
  final String description;

  const HeatmapLegendItem({
    required this.color,
    required this.label,
    required this.description,
  });
}
