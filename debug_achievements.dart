import 'package:flutter/material.dart';
import 'lib/services/database_service.dart';
import 'lib/services/achievement_service.dart';
import 'lib/models/achievement.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Initializing database service...');
    final dbService = await DatabaseService.getInstance();
    await dbService.initialize();
    print('Database service initialized successfully');
    
    print('Initializing achievement service...');
    final achievementService = await AchievementService.getInstance();
    await achievementService.initialize();
    print('Achievement service initialized successfully');
    
    print('Getting all achievements...');
    final achievements = await achievementService.getAllAchievements();
    print('Found ${achievements.length} achievements:');
    
    for (final achievement in achievements) {
      print('- ${achievement.title}: ${achievement.description}');
      print('  Type: ${achievement.type}, Target: ${achievement.targetValue}');
      print('  Progress: ${achievement.currentProgress}, Earned: ${achievement.isEarned}');
      print('');
    }
    
    print('Getting earned achievements...');
    final earnedAchievements = await achievementService.getEarnedAchievements();
    print('Found ${earnedAchievements.length} earned achievements');
    
    print('Getting unearned achievements...');
    final unearnedAchievements = await achievementService.getUnearnedAchievements();
    print('Found ${unearnedAchievements.length} unearned achievements');
    
    print('Achievement debug completed successfully!');
    
  } catch (e, stackTrace) {
    print('ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}