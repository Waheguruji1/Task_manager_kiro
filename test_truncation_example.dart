import 'package:flutter/material.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/widgets/task_item.dart';
import 'package:task_manager_kiro/widgets/truncated_text.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  runApp(TruncationTestApp());
}

class TruncationTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Truncation Test',
      theme: AppTheme.darkTheme,
      home: TruncationTestScreen(),
    );
  }
}

class TruncationTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create test tasks with long titles and descriptions
    final longTask = Task(
      id: 1,
      title: 'This is a very long task title that should definitely be truncated when displayed in the UI components to maintain proper layout and readability',
      description: 'This is an extremely long description that contains a lot of details about the task. It should be truncated to prevent the UI from becoming cluttered and maintain good user experience. The description can contain multiple sentences and should handle truncation gracefully.',
      createdAt: DateTime.now(),
      priority: TaskPriority.high,
    );

    final mediumTask = Task(
      id: 2,
      title: 'Medium length task title that might need truncation',
      description: 'A medium length description that might or might not be truncated depending on the limits.',
      createdAt: DateTime.now(),
      priority: TaskPriority.medium,
    );

    final shortTask = Task(
      id: 3,
      title: 'Short task',
      description: 'Short desc',
      createdAt: DateTime.now(),
      priority: TaskPriority.none,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Text Truncation Test'),
        backgroundColor: AppTheme.greyDark,
      ),
      backgroundColor: AppTheme.backgroundDark,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Items with Truncation:',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 16),
            
            // Long task
            TaskItem(
              task: longTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
            
            SizedBox(height: 16),
            
            // Medium task
            TaskItem(
              task: mediumTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
            
            SizedBox(height: 16),
            
            // Short task
            TaskItem(
              task: shortTask,
              onToggle: (value) {},
              onEdit: () {},
              onDelete: () {},
            ),
            
            SizedBox(height: 32),
            
            Text(
              'Standalone TruncatedText Examples:',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 16),
            
            // Standalone TruncatedText examples
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderWhite),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Long text with truncation:', style: AppTheme.bodyMedium),
                  SizedBox(height: 8),
                  TruncatedText(
                    text: 'This is a very long text that should be truncated and provide expand/collapse functionality for better user experience and interface cleanliness.',
                    maxLength: 60,
                    style: AppTheme.bodyLarge,
                  ),
                  
                  SizedBox(height: 16),
                  
                  Text('Short text (no truncation):', style: AppTheme.bodyMedium),
                  SizedBox(height: 8),
                  TruncatedText(
                    text: 'This is short text.',
                    maxLength: 60,
                    style: AppTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            Text(
              'Task Model Helper Methods:',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderWhite),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Original title: ${longTask.title}', style: AppTheme.caption),
                  SizedBox(height: 4),
                  Text('Truncated title: ${longTask.getTruncatedTitle()}', style: AppTheme.bodyMedium),
                  Text('Is truncated: ${longTask.isTitleTruncated}', style: AppTheme.caption),
                  
                  SizedBox(height: 16),
                  
                  Text('Original description: ${longTask.description}', style: AppTheme.caption),
                  SizedBox(height: 4),
                  Text('Truncated description: ${longTask.getTruncatedDescription()}', style: AppTheme.bodyMedium),
                  Text('Is truncated: ${longTask.isDescriptionTruncated}', style: AppTheme.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}