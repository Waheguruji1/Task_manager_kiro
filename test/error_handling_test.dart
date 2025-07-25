import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/utils/error_handler.dart';
import 'package:task_manager_kiro/utils/validation.dart';
import 'package:task_manager_kiro/utils/constants.dart';
import 'package:task_manager_kiro/utils/theme.dart';
import 'package:task_manager_kiro/widgets/error_boundary.dart';

void main() {
  group('Error Handling Tests', () {
    testWidgets('ErrorDisplayWidget should show error message and retry button', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ErrorDisplayWidget(
              message: 'Test error message',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      // Verify error message is displayed
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Verify retry callback was called
      expect(retryPressed, true);
    });

    testWidgets('LoadingWidget should show loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LoadingWidget(message: 'Loading test...'),
          ),
        ),
      );

      // Verify loading indicator and message are displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading test...'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget should show empty state with action button', (WidgetTester tester) async {
      bool actionPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No items',
              subtitle: 'Add your first item',
              actionText: 'Add Item',
              onAction: () => actionPressed = true,
            ),
          ),
        ),
      );

      // Verify empty state elements are displayed
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      // Tap action button
      await tester.tap(find.text('Add Item'));
      await tester.pump();

      // Verify action callback was called
      expect(actionPressed, true);
    });

    testWidgets('FormErrorBoundary should show validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FormErrorBoundary(
              child: const Text('Form content'),
            ),
          ),
        ),
      );

      // Verify form content is displayed
      expect(find.text('Form content'), findsOneWidget);
    });

    test('ErrorHandler should format error messages correctly', () {
      // Test database error handling
      final dbError = Exception('Database connection failed');
      final dbMessage = ErrorHandler.handleDatabaseError(dbError);
      expect(dbMessage, contains('Unable to connect to database'));

      // Test preferences error handling
      final prefsError = Exception('Preferences error');
      final prefsMessage = ErrorHandler.handlePreferencesError(prefsError);
      expect(prefsMessage, AppStrings.errorPreferences);

      // Test validation error handling
      final validationError = Exception('Validation failed');
      final validationMessage = ErrorHandler.handleValidationError(validationError);
      expect(validationMessage, AppStrings.errorValidation);

      // Test unknown error handling
      final unknownError = Exception('Unknown error');
      final unknownMessage = ErrorHandler.handleUnknownError(unknownError);
      expect(unknownMessage, AppStrings.errorGeneral);
    });

    test('AppException should store error details correctly', () {
      const message = 'Test error message';
      const type = ErrorType.database;
      final originalError = Exception('Original error');
      
      final appException = AppException(
        message: message,
        type: type,
        originalError: originalError,
      );

      expect(appException.message, message);
      expect(appException.type, type);
      expect(appException.originalError, originalError);
      expect(appException.toString(), contains(message));
      expect(appException.toString(), contains(type.name));
    });
  });

  group('Validation Tests', () {
    test('validateUserName should validate correctly', () {
      // Test empty name
      expect(ValidationUtils.validateUserName(''), AppStrings.validationNameRequired);
      expect(ValidationUtils.validateUserName(null), AppStrings.validationNameRequired);
      expect(ValidationUtils.validateUserName('   '), AppStrings.validationNameRequired);

      // Test valid name
      expect(ValidationUtils.validateUserName('John'), null);
      expect(ValidationUtils.validateUserName('  John  '), null);

      // Test name too long
      final longName = 'a' * (AppConstants.maxUserNameLength + 1);
      expect(ValidationUtils.validateUserName(longName), AppStrings.validationNameTooLong);

      // Test invalid characters
      expect(ValidationUtils.validateUserName('John<script>'), contains('invalid characters'));
    });

    test('validateTaskTitle should validate correctly', () {
      // Test empty title
      expect(ValidationUtils.validateTaskTitle(''), AppStrings.validationTaskTitleRequired);
      expect(ValidationUtils.validateTaskTitle(null), AppStrings.validationTaskTitleRequired);
      expect(ValidationUtils.validateTaskTitle('   '), AppStrings.validationTaskTitleRequired);

      // Test valid title
      expect(ValidationUtils.validateTaskTitle('Buy groceries'), null);
      expect(ValidationUtils.validateTaskTitle('  Buy groceries  '), null);

      // Test title too long
      final longTitle = 'a' * (AppConstants.maxTaskTitleLength + 1);
      expect(ValidationUtils.validateTaskTitle(longTitle), AppStrings.validationTaskTitleTooLong);
    });

    test('validateTaskDescription should validate correctly', () {
      // Test null description (should be valid as it's optional)
      expect(ValidationUtils.validateTaskDescription(null), null);

      // Test empty description (should be valid)
      expect(ValidationUtils.validateTaskDescription(''), null);

      // Test valid description
      expect(ValidationUtils.validateTaskDescription('This is a valid description'), null);

      // Test description too long
      final longDescription = 'a' * (AppConstants.maxTaskDescriptionLength + 1);
      expect(ValidationUtils.validateTaskDescription(longDescription), AppStrings.validationTaskDescriptionTooLong);
    });

    test('validateTaskId should validate correctly', () {
      // Test null ID
      expect(ValidationUtils.validateTaskId(null), contains('Invalid task ID'));

      // Test invalid ID
      expect(ValidationUtils.validateTaskId(0), contains('Invalid task ID'));
      expect(ValidationUtils.validateTaskId(-1), contains('Invalid task ID'));

      // Test valid ID
      expect(ValidationUtils.validateTaskId(1), null);
      expect(ValidationUtils.validateTaskId(100), null);
    });

    test('validateDateString should validate correctly', () {
      // Test null date
      expect(ValidationUtils.validateDateString(null), contains('Date cannot be empty'));

      // Test empty date
      expect(ValidationUtils.validateDateString(''), contains('Date cannot be empty'));
      expect(ValidationUtils.validateDateString('   '), contains('Date cannot be empty'));

      // Test invalid date format
      expect(ValidationUtils.validateDateString('invalid-date'), contains('Invalid date format'));
      expect(ValidationUtils.validateDateString('not-a-date'), contains('Invalid date format'));

      // Test valid date format
      expect(ValidationUtils.validateDateString('2023-12-01'), null);
      expect(ValidationUtils.validateDateString('2023-12-01T10:30:00'), null);
    });

    test('sanitizeInput should clean input correctly', () {
      // Test basic trimming
      expect(ValidationUtils.sanitizeInput('  hello  '), 'hello');

      // Test removing harmful characters
      expect(ValidationUtils.sanitizeInput('hello<script>world'), 'helloscriptworld');
      expect(ValidationUtils.sanitizeInput('test"quote'), 'testquote');
      expect(ValidationUtils.sanitizeInput('path\\slash'), 'pathslash');

      // Test multiple spaces
      expect(ValidationUtils.sanitizeInput('hello    world'), 'hello world');
      expect(ValidationUtils.sanitizeInput('  hello    world  '), 'hello world');
    });

    test('utility validation methods should work correctly', () {
      // Test isValidNonEmptyString
      expect(ValidationUtils.isValidNonEmptyString('hello'), true);
      expect(ValidationUtils.isValidNonEmptyString(''), false);
      expect(ValidationUtils.isValidNonEmptyString(null), false);
      expect(ValidationUtils.isValidNonEmptyString('   '), false);

      // Test exceedsMaxLength
      expect(ValidationUtils.exceedsMaxLength('hello', 10), false);
      expect(ValidationUtils.exceedsMaxLength('hello', 3), true);
      expect(ValidationUtils.exceedsMaxLength(null, 10), false);

      // Test belowMinLength
      expect(ValidationUtils.belowMinLength('hello', 3), false);
      expect(ValidationUtils.belowMinLength('hi', 3), true);
      expect(ValidationUtils.belowMinLength(null, 3), true);
      expect(ValidationUtils.belowMinLength('   ', 3), true);
    });

    test('additional validation methods should work correctly', () {
      // Test validateRequired
      expect(ValidationUtils.validateRequired('value', 'Field'), null);
      expect(ValidationUtils.validateRequired('', 'Field'), 'Field is required');
      expect(ValidationUtils.validateRequired(null, 'Field'), 'Field is required');

      // Test validateMinLength
      expect(ValidationUtils.validateMinLength('hello', 3, 'Field'), null);
      expect(ValidationUtils.validateMinLength('hi', 3, 'Field'), 'Field must be at least 3 characters');

      // Test validateMaxLength
      expect(ValidationUtils.validateMaxLength('hello', 10, 'Field'), null);
      expect(ValidationUtils.validateMaxLength('hello world!', 5, 'Field'), 'Field must be less than 5 characters');

      // Test validateNumeric
      expect(ValidationUtils.validateNumeric('123', 'Field'), null);
      expect(ValidationUtils.validateNumeric('123.45', 'Field'), null);
      expect(ValidationUtils.validateNumeric('abc', 'Field'), 'Field must be a valid number');
      expect(ValidationUtils.validateNumeric('', 'Field'), 'Field is required');

      // Test validatePositiveNumber
      expect(ValidationUtils.validatePositiveNumber('123', 'Field'), null);
      expect(ValidationUtils.validatePositiveNumber('123.45', 'Field'), null);
      expect(ValidationUtils.validatePositiveNumber('0', 'Field'), 'Field must be a positive number');
      expect(ValidationUtils.validatePositiveNumber('-5', 'Field'), 'Field must be a positive number');
    });
  });

  group('Form Validation Helper Tests', () {
    test('validateTaskForm should validate task form data', () {
      // Test valid form
      final validForm = FormValidationHelper.validateTaskForm(
        title: 'Valid title',
        description: 'Valid description',
      );
      expect(FormValidationHelper.hasErrors(validForm), false);

      // Test invalid form
      final invalidForm = FormValidationHelper.validateTaskForm(
        title: '',
        description: 'a' * (AppConstants.maxTaskDescriptionLength + 1),
      );
      expect(FormValidationHelper.hasErrors(invalidForm), true);
      expect(invalidForm['title'], AppStrings.validationTaskTitleRequired);
      expect(invalidForm['description'], AppStrings.validationTaskDescriptionTooLong);
    });

    test('validateUserForm should validate user form data', () {
      // Test valid form
      final validForm = FormValidationHelper.validateUserForm(name: 'John');
      expect(FormValidationHelper.hasErrors(validForm), false);

      // Test invalid form
      final invalidForm = FormValidationHelper.validateUserForm(name: '');
      expect(FormValidationHelper.hasErrors(invalidForm), true);
      expect(invalidForm['name'], AppStrings.validationNameRequired);
    });

    test('getFirstError should return first error message', () {
      final errors = {
        'field1': 'Error 1',
        'field2': 'Error 2',
        'field3': null,
      };
      
      expect(FormValidationHelper.getFirstError(errors), 'Error 1');
      
      final noErrors = {
        'field1': null,
        'field2': null,
      };
      
      expect(FormValidationHelper.getFirstError(noErrors), null);
    });
  });
}