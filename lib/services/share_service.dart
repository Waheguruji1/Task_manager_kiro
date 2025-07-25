import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';

/// Share Service
/// 
/// Handles app sharing functionality using the share_plus package.
/// Provides methods to share the app and individual tasks with proper error handling.
class ShareService {
  ShareService._();
  
  /// Share the app with others
  static Future<bool> shareApp() async {
    try {
      await Share.share(
        AppStrings.shareAppText,
        subject: AppConstants.appName,
      );
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Share app', type: ErrorType.unknown);
      return false;
    }
  }
  
  /// Share app with custom text
  static Future<bool> shareAppWithText(String customText) async {
    try {
      // Validate input
      if (customText.trim().isEmpty) {
        throw AppException(
          message: 'Share text cannot be empty',
          type: ErrorType.validation,
        );
      }

      await Share.share(
        customText.trim(),
        subject: AppConstants.appName,
      );
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Share app with custom text', type: ErrorType.unknown);
      if (e is AppException) {
        rethrow;
      }
      return false;
    }
  }
  
  /// Share app with additional context (like user's task count)
  static Future<bool> shareAppWithStats({
    int? totalTasks,
    int? completedTasks,
    int? routineTasks,
  }) async {
    try {
      // Validate input
      if (totalTasks != null && totalTasks < 0) {
        throw AppException(
          message: 'Total tasks cannot be negative',
          type: ErrorType.validation,
        );
      }
      if (completedTasks != null && completedTasks < 0) {
        throw AppException(
          message: 'Completed tasks cannot be negative',
          type: ErrorType.validation,
        );
      }
      if (routineTasks != null && routineTasks < 0) {
        throw AppException(
          message: 'Routine tasks cannot be negative',
          type: ErrorType.validation,
        );
      }

      String shareText = '${AppConstants.appName} - ${AppConstants.appDescription}\n\n';
      
      if (totalTasks != null) {
        shareText += 'I\'ve been using this amazing task manager and have ';
        if (completedTasks != null) {
          shareText += 'completed $completedTasks out of $totalTasks tasks! ';
        } else {
          shareText += 'organized $totalTasks tasks! ';
        }
        
        if (routineTasks != null && routineTasks > 0) {
          shareText += 'It even helps me manage $routineTasks routine tasks. ';
        }
        
        shareText += '\n\n';
      }
      
      shareText += 'Download it and stay organized!';
      
      await Share.share(
        shareText,
        subject: AppConstants.appName,
      );
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Share app with stats', type: ErrorType.unknown);
      if (e is AppException) {
        rethrow;
      }
      return false;
    }
  }

  /// Share a specific task
  static Future<bool> shareTask(String taskTitle, {String? taskDescription}) async {
    try {
      // Validate input
      if (taskTitle.trim().isEmpty) {
        throw AppException(
          message: 'Task title cannot be empty for sharing',
          type: ErrorType.validation,
        );
      }

      String shareText = '${AppStrings.shareTaskText}${taskTitle.trim()}';
      
      if (taskDescription != null && taskDescription.trim().isNotEmpty) {
        shareText += '\n\nDescription: ${taskDescription.trim()}';
      }
      
      shareText += '\n\nShared from ${AppConstants.appName}';
      
      await Share.share(shareText, subject: 'Task: ${taskTitle.trim()}');
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Share task', type: ErrorType.unknown);
      if (e is AppException) {
        rethrow;
      }
      return false;
    }
  }

  /// Share multiple tasks
  static Future<bool> shareTaskList(List<String> taskTitles) async {
    try {
      // Validate input
      if (taskTitles.isEmpty) {
        throw AppException(
          message: 'No tasks to share',
          type: ErrorType.validation,
        );
      }

      final validTasks = taskTitles.where((title) => title.trim().isNotEmpty).toList();
      if (validTasks.isEmpty) {
        throw AppException(
          message: 'No valid tasks to share',
          type: ErrorType.validation,
        );
      }

      String shareText = 'My Tasks:\n\n';
      for (int i = 0; i < validTasks.length; i++) {
        shareText += '${i + 1}. ${validTasks[i].trim()}\n';
      }
      
      shareText += '\nShared from ${AppConstants.appName}';
      
      await Share.share(shareText, subject: 'My Task List');
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Share task list', type: ErrorType.unknown);
      if (e is AppException) {
        rethrow;
      }
      return false;
    }
  }
  
  /// Check if sharing is available on the platform
  static Future<bool> canShare() async {
    try {
      // share_plus package handles platform availability internally
      // This method is for future extensibility
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check share availability', type: ErrorType.unknown);
      return false;
    }
  }
}