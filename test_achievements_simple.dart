import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/providers/providers.dart';

void main() {
  runApp(const TestAchievementsApp());
}

class TestAchievementsApp extends StatelessWidget {
  const TestAchievementsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Test Achievements',
        home: const TestAchievementsScreen(),
      ),
    );
  }
}

class TestAchievementsScreen extends ConsumerWidget {
  const TestAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Achievements')),
      body: achievementsAsync.when(
        data: (achievements) {
          print('SUCCESS: Got ${achievements.length} achievements');
          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return ListTile(
                title: Text(achievement.title),
                subtitle: Text(achievement.description),
                trailing: achievement.isEarned 
                  ? const Icon(Icons.check, color: Colors.green)
                  : Text('${achievement.currentProgress}/${achievement.targetValue}'),
              );
            },
          );
        },
        loading: () {
          print('LOADING: Achievements are loading...');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          print('ERROR: Failed to load achievements: $error');
          print('STACK: $stack');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allAchievementsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}