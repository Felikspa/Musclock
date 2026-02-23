import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'heatmap_color.dart';

/// Vertical bar chart widget for heatmap visualization
/// Displays training data as vertical bars growing upward from left to right
class HeatmapBarChart extends StatelessWidget {
  /// Map of date to training points
  final Map<DateTime, double> trainingPoints;
  
  /// Maximum training points for color normalization
  final double maxTP;
  
  /// Number of days to display
  final int days;
  
  /// Locale for date formatting
  final String locale;

  const HeatmapBarChart({
    super.key,
    required this.trainingPoints,
    required this.maxTP,
    required this.days,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Generate date range from oldest to newest (left to right)
    final startDate = now.subtract(Duration(days: days - 1));
    final dateFormat = DateFormat('d', locale);

    return Column(
      children: [
        // Bar chart area
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(days, (index) {
              final date = startDate.add(Duration(days: index));
              final dateKey = DateTime(date.year, date.month, date.day);
              final tp = trainingPoints[dateKey] ?? 0.0;
              
              // Calculate bar height (minimum 4px if there's training, 0 if none)
              final normalizedTP = maxTP > 0 ? (tp / maxTP).clamp(0.0, 1.0) : 0.0;
              final barHeight = tp > 0 ? (normalizedTP * 100).clamp(4.0, 100.0) : 0.0;
              
              // Get color using HeatmapColor
              final barColor = HeatmapColor.getColor(tp, maxTP);
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Date labels
        Row(
          children: List.generate(days, (index) {
            final date = startDate.add(Duration(days: index));
            final isToday = index == days - 1;
            final isYesterday = index == days - 2;
            
            // Show date label at specific positions
            String label = '';
            if (isToday) {
              label = locale == 'zh' ? '今天' : 'Today';
            } else if (isYesterday) {
              label = locale == 'zh' ? '昨天' : 'Yesterday';
            } else if (index == 0 || index == days - 1 || index == (days ~/ 2)) {
              label = dateFormat.format(date);
            }
            
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday 
                        ? (isDark ? Colors.white : Colors.black87)
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
