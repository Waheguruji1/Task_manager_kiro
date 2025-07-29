import 'package:flutter/material.dart';
import 'package:task_manager_kiro/widgets/heatmap_widget.dart';

/// Example usage of HeatmapWidget for demonstration purposes
class HeatmapExample extends StatelessWidget {
  const HeatmapExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Heatmap Examples'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Single value heatmap example
            HeatmapWidget(
              data: _generateSampleCompletionData(),
              baseColor: Colors.purple,
              title: 'Task Completion Activity',
              onCellTap: (date, value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${date.day}/${date.month}: $value tasks'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltipBuilder: (date, value) => Text(
                '${date.day}/${date.month}\n$value tasks completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Multi-value heatmap example
            HeatmapWidget(
              data: _generateSampleCreationCompletionData(),
              baseColor: Colors.green,
              title: 'Task Creation vs Completion',
              isMultiValue: true,
              onCellTap: (date, value) {
                if (value is Map<String, int>) {
                  final created = value['created'] ?? 0;
                  final completed = value['completed'] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${date.day}/${date.month}: $created created, $completed completed',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              tooltipBuilder: (date, value) {
                if (value is Map<String, int>) {
                  final created = value['created'] ?? 0;
                  final completed = value['completed'] ?? 0;
                  return Text(
                    '${date.day}/${date.month}\nCreated: $created\nCompleted: $completed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return const Text('No data');
              },
            ),
            const SizedBox(height: 24),
            // Compact heatmap example
            HeatmapWidget(
              data: _generateSampleCompletionData(),
              baseColor: Colors.blue,
              title: 'Compact View',
              cellSize: 8.0,
              spacing: 1.0,
              tooltipBuilder: (date, value) => Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate sample completion data for demonstration
  Map<DateTime, int> _generateSampleCompletionData() {
    final data = <DateTime, int>{};
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    
    // Generate random data for the year
    for (int i = 0; i < 365; i++) {
      final date = startOfYear.add(Duration(days: i));
      if (date.isBefore(now) || date.isAtSameMomentAs(now)) {
        // Simulate varying activity levels
        final dayOfWeek = date.weekday;
        final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;
        final baseActivity = isWeekend ? 2 : 5;
        
        // Add some randomness
        final random = (date.day * date.month) % 10;
        data[date] = baseActivity + random;
      }
    }
    
    return data;
  }

  /// Generate sample creation vs completion data for demonstration
  Map<DateTime, Map<String, int>> _generateSampleCreationCompletionData() {
    final data = <DateTime, Map<String, int>>{};
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    
    // Generate random data for the year
    for (int i = 0; i < 365; i++) {
      final date = startOfYear.add(Duration(days: i));
      if (date.isBefore(now) || date.isAtSameMomentAs(now)) {
        // Simulate varying creation and completion patterns
        final dayOfWeek = date.weekday;
        final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;
        
        final random = (date.day * date.month) % 8;
        final created = isWeekend ? 1 + random : 3 + random;
        final completed = (created * 0.8).round() + (random % 2);
        
        data[date] = {
          'created': created,
          'completed': completed,
        };
      }
    }
    
    return data;
  }
}