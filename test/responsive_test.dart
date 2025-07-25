import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/utils/responsive.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    testWidgets('should return correct screen size for different widths', (WidgetTester tester) async {
      // Test mobile screen size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenSize = ResponsiveUtils.getScreenSize(context);
              expect(screenSize, ScreenSize.mobile);
              return Container();
            },
          ),
        ),
      );

      // Test tablet screen size
      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenSize = ResponsiveUtils.getScreenSize(context);
              expect(screenSize, ScreenSize.tablet);
              return Container();
            },
          ),
        ),
      );

      // Test desktop screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenSize = ResponsiveUtils.getScreenSize(context);
              expect(screenSize, ScreenSize.desktop);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect orientation correctly', (WidgetTester tester) async {
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isPortrait(context), true);
              expect(ResponsiveUtils.isLandscape(context), false);
              return Container();
            },
          ),
        ),
      );

      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isLandscape(context), true);
              expect(ResponsiveUtils.isPortrait(context), false);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should provide appropriate responsive values', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getScreenPadding(context);
              final contentWidth = ResponsiveUtils.getContentWidth(context);
              final fontMultiplier = ResponsiveUtils.getFontSizeMultiplier(context);
              
              expect(padding, isA<EdgeInsets>());
              expect(contentWidth, greaterThan(0));
              expect(fontMultiplier, greaterThan(0));
              
              return Container();
            },
          ),
        ),
      );
    });
  });

  group('ResponsiveBuilder Tests', () {
    testWidgets('should provide correct context to builder', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenSize, isLandscape) {
              expect(screenSize, ScreenSize.mobile);
              expect(isLandscape, false);
              return const Text('Test');
            },
          ),
        ),
      );
      
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('ResponsiveLayout Tests', () {
    testWidgets('should show correct widget for screen size', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );
      
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);

      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(700, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );
      
      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });
  });
}