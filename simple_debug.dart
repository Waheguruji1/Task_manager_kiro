import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() async {
  try {
    print('Checking database file...');
    
    // Get the app's documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'task_manager.db'));
    
    print('Database path: ${dbFile.path}');
    print('Database exists: ${dbFile.existsSync()}');
    
    if (dbFile.existsSync()) {
      final stats = dbFile.statSync();
      print('Database size: ${stats.size} bytes');
      print('Database modified: ${stats.modified}');
    }
    
  } catch (e, stackTrace) {
    print('ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}