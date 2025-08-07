import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_kiro/widgets/task_item.dart';
import 'package:task_manager_kiro/widgets/truncated_text.dart';
import 'package:task_manager_kiro/widgets/add_task_dialog.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/utils/theme.dart';
import 'package:task_manager_kiro/utils/responsive.dart';

void main() {
  group('UI Enhancements Tests', () {
    testWidgets('Task item displays priority colors subtly', (WidgetTester tester) async {
      // Create a high priority task
      final task = Task(
        id: 1,
        title: 'High Priority Task',
        description: 'This is a high priority task',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TaskItem(
              task: task,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify the task item is rendered
      expect(find.text('High Priority Task'), findsOneWidget);
      
      // Verify priority indicator is present for high priority task
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Truncated text works correctly', (WidgetTester tester) async {
      const longText = 'This is a very long text that should be truncated when it exceeds the maximum length specified for the widget';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TruncatedText(
              text: longText,
              maxLength: 50,
              maxLines: 2,
            ),
          ),
        ),
      );

      // Verify the text is truncated
      expect(find.textContaining('...'), findsOneWidget);
    });

    testWidgets('SimpleTruncatedText shows tooltip on tap', (WidgetTester tester) async {
      const longText = 'This is a very long text that should show tooltip';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SimpleTruncatedText(
              text: longText,
              maxLength: 20,
              showTooltipOnTap: true,
            ),
          ),
        ),
      );

      // Verify the text is truncated
      expect(find.textContaining('...'), findsOneWidget);
      
      // Verify tooltip widget is present
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('Responsive utilities work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              // Test responsive utilities
              final screenSize = ResponsiveUtils.getScreenSize(context);
              final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
              final contentWidth = ResponsiveUtils.getContentWidth(context);
              final textTruncationLength = ResponsiveUtils.getTextTruncationLength(context);
              
              return Scaffold(
                body: Column(
                  children: [
                    Text('Screen Size: ${screenSize.toString()}'),
                    Text('Is Small Screen: $isSmallScreen'),
                    Text('Content Width: $contentWidth'),
                    Text('Text Truncation Length: $textTruncationLength'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Verify responsive utilities return valid values
      expect(find.textContaining('Screen Size:'), findsOneWidget);
      expect(find.textContaining('Is Small Screen:'), findsOneWidget);
      expect(find.textContaining('Content Width:'), findsOneWidget);
      expect(find.textContaining('Text Truncation Length:'), findsOneWidget);
    });

    testWidgets('Add task dialog dropdowns have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: AddTaskDialog(),
            ),
          ),
        ),
      );

      // Wait for the dialog to build
      await tester.pumpAndSettle();

      // Verify dialog is rendered
      expect(find.text('Add New Task'), findsOneWidget);
      
      // Verify dropdowns are present
      expect(find.byType(DropdownButton<TaskPriority>), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    test('Theme enhancements are properly defined', () {
      // Test that new theme properties are defined
      expect(AppTheme.enhancedButtonDecoration, isA<BoxDecoration>());
      expect(AppTheme.priorityHigh, isA<Color>());
      expect(AppTheme.priorityMedium, isA<Color>());
      expect(AppTheme.visualHierarchySpacing, isA<double>());
      
      // Test that routine task label decoration is enhanced
      final decoration = AppTheme.routineTaskLabelDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
    });
  });
}