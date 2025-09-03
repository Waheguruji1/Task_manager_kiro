import 'database_service.dart';

class DataCleanupService {
  final DatabaseService _databaseService;

  DataCleanupService(this._databaseService);

  /// Clean up all data except current year
  Future<void> cleanupOldData() async {
    final currentYear = DateTime.now().year;
    final startOfYear = DateTime(currentYear, 1, 1);

    try {
      // Delete tasks from previous years
      await _databaseService.deleteTasksBeforeDate(startOfYear);

      // Note: We keep user data and achievements as they're not date-specific
      print('Data cleanup completed - kept only $currentYear data');
    } catch (e) {
      print('Error during data cleanup: $e');
      rethrow;
    }
  }

  /// Get data storage info
  Future<Map<String, int>> getDataInfo() async {
    final currentYear = DateTime.now().year;
    final startOfYear = DateTime(currentYear, 1, 1);

    final allTasks = await _databaseService.getAllTasks();
    final currentYearTasks = allTasks
        .where((task) =>
            task.createdAt.isAfter(startOfYear) ||
            task.createdAt.isAtSameMomentAs(startOfYear))
        .length;

    final oldTasks = allTasks.length - currentYearTasks;

    return {
      'currentYearTasks': currentYearTasks,
      'oldTasks': oldTasks,
      'totalTasks': allTasks.length,
    };
  }
}
