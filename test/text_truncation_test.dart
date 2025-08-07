import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/widgets/truncated_text.dart';
import 'package:task_manager_kiro/widgets/task_item.dart';

void main() {
  group('Text Truncation Tests', () {
    testWidgets('TruncatedText shows full text when under limit', (WidgetTester tester) async {
      const shortText = 'Short text';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TruncatedText(
              text: shortText,
              maxLength: 50,
            ),
          ),
        ),
      );

      expect(find.text(shortText), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('TruncatedText truncates long text and shows expand option', (WidgetTester tester) async {
      const longText = 'This is a very long text that should definitely be truncated because it exceeds the maximum length limit';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TruncatedText(
              text: longText,
              maxLength: 50,
            ),
          ),
        ),
      );

      // Should show truncated text
      expect(find.textContaining('...'), findsOneWidget);
      expect(find.text('Show more'), findsOneWidget);
      expect(find.text(longText), findsNothing);
    });

    testWidgets('TruncatedText shows truncation correctly', (WidgetTester tester) async {
      const longText = 'This is a very long text that should definitely be truncated because it exceeds the maximum length limit';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TruncatedText(
              text: longText,
              maxLength: 50,
            ),
          ),
        ),
      );

      // Should show truncated text and expand option
      expect(find.textContaining('...'), findsOneWidget);
      expect(find.text('Show more'), findsOneWidget);
      
      // Should not show the full text initially
      expect(find.text(longText), findsNothing);
    });

    testWidgets('SimpleTruncatedText shows tooltip for long text', (WidgetTester tester) async {
      const longText = 'This is a very long text that should be truncated';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimpleTruncatedText(
              text: longText,
              maxLength: 20,
            ),
          ),
        ),
      );

      // Should show truncated text with ellipsis
      expect(find.textContaining('...'), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    test('Task model truncation methods work correctly', () {
      // Test task with long title
      final taskWithLongTitle = Task(
        title: 'This is a very long task title that should be truncated when displayed in the UI',
        description: 'This is a very long description that should also be truncated when displayed in the task item widget',
        createdAt: DateTime.now(),
      );

      // Test title truncation
      expect(taskWithLongTitle.getTruncatedTitle().length, lessThanOrEqualTo(53)); // 50 + '...'
      expect(taskWithLongTitle.getTruncatedTitle(), endsWith('...'));
      expect(taskWithLongTitle.isTitleTruncated, isTrue);

      // Test description truncation
      expect(taskWithLongTitle.getTruncatedDescription()!.length, lessThanOrEqualTo(83)); // 80 + '...'
      expect(taskWithLongTitle.getTruncatedDescription(), endsWith('...'));
      expect(taskWithLongTitle.isDescriptionTruncated, isTrue);

      // Test task with short title
      final taskWithShortTitle = Task(
        title: 'Short title',
        description: 'Short desc',
        createdAt: DateTime.now(),
      );

      expect(taskWithShortTitle.getTruncatedTitle(), equals('Short title'));
      expect(taskWithShortTitle.isTitleTruncated, isFalse);
      expect(taskWithShortTitle.getTruncatedDescription(), equals('Short desc'));
      expect(taskWithShortTitle.isDescriptionTruncated, isFalse);
    });

    testWidgets('TaskItem displays truncated text correctly', (WidgetTester tester) async {
      final longTask = Task(
        title: 'This is a very long task title that should be truncated when displayed in the UI components',
        description: 'This is a very long description that should also be truncated when displayed in the task item widget for better user experience',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: longTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should find TruncatedText widgets
      expect(find.byType(TruncatedText), findsAtLeast(1));
      
      // Should show truncated content
      expect(find.textContaining('...'), findsAtLeast(1));
    });
  });
}