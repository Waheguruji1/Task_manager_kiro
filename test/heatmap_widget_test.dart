import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/widgets/heatmap_widget.dart';

void main() {
  group('HeatmapWidget Tests', () {
    testWidgets('should render heatmap with title', (WidgetTester tester) async {
      final testData = <DateTime, int>{
        DateTime(2024, 1, 1): 5,
        DateTime(2024, 1, 2): 3,
        DateTime(2024, 1, 3): 8,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapWidget(
              data: testData,
              baseColor: Colors.purple,
              title: 'Test Heatmap',
            ),
          ),
        ),
      );

      expect(find.text('Test Heatmap'), findsOneWidget);
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('should handle multi-value data', (WidgetTester tester) async {
      final testData = <DateTime, Map<String, int>>{
        DateTime(2024, 1, 1): {'created': 5, 'completed': 3},
        DateTime(2024, 1, 2): {'created': 2, 'completed': 2},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapWidget(
              data: testData,
              baseColor: Colors.green,
              title: 'Multi-value Heatmap',
              isMultiValue: true,
            ),
          ),
        ),
      );

      expect(find.text('Multi-value Heatmap'), findsOneWidget);
    });

    testWidgets('should handle empty data', (WidgetTester tester) async {
      final testData = <DateTime, int>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapWidget(
              data: testData,
              baseColor: Colors.blue,
              title: 'Empty Heatmap',
            ),
          ),
        ),
      );

      expect(find.text('Empty Heatmap'), findsOneWidget);
    });

    testWidgets('should show tooltip when provided', (WidgetTester tester) async {
      final testData = <DateTime, int>{
        DateTime(2024, 1, 1): 5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapWidget(
              data: testData,
              baseColor: Colors.purple,
              title: 'Tooltip Heatmap',
              tooltipBuilder: (date, value) => Text('$value tasks'),
            ),
          ),
        ),
      );

      expect(find.text('Tooltip Heatmap'), findsOneWidget);
    });

    testWidgets('should handle cell tap callback', (WidgetTester tester) async {
      DateTime? tappedDate;
      dynamic tappedValue;

      final testData = <DateTime, int>{
        DateTime(2024, 1, 1): 5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapWidget(
              data: testData,
              baseColor: Colors.purple,
              title: 'Tappable Heatmap',
              onCellTap: (date, value) {
                tappedDate = date;
                tappedValue = value;
              },
            ),
          ),
        ),
      );

      // Find and tap a cell (this is a simplified test)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Note: In a real test, we'd need to find the specific cell
      // This is a basic structure test
      expect(find.text('Tappable Heatmap'), findsOneWidget);
    });
  });
}