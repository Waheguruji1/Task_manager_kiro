import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../widgets/custom_app_bar.dart';

/// Achievements Screen displaying user progress and milestones
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Achievements',
        showShareButton: false,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final achievementsAsync = ref.watch(allAchievementsProvider);
          
          return achievementsAsync.when(
            data: (achievements) => RefreshIndicator(
              onRefresh: () => ref.refresh(allAchievementsProvider.future),
              color: AppTheme.greyPrimary,
              backgroundColor: AppTheme.surfaceGrey,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, AppTheme.spacingM)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(achievements),
                    const SizedBox(height: AppTheme.spacingXL),
                    _buildMilestonesSection(achievements),
                  ],
                ),
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.greyPrimary,
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Failed to load achievements',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allAchievementsProvider.future),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection(List<Achievement> achievements) {
    final earnedCount = achievements.where((a) => a.isEarned).length;
    final totalCount = achievements.length;

    // Calculate task-related progress (mock data for now)
    final tasksCompleted = 6;
    final totalTasks = 10;
    final projectsFinished = 2;
    final totalProjects = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: AppTheme.headingLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        
        // Tasks Completed Progress
        _buildProgressItem(
          'Tasks Completed',
          tasksCompleted,
          totalTasks,
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Projects Finished Progress
        _buildProgressItem(
          'Projects Finished',
          projectsFinished,
          totalProjects,
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Achievements Progress
        _buildProgressItem(
          'Achievements Earned',
          earnedCount,
          totalCount,
        ),
      ],
    );
  }

  Widget _buildProgressItem(String title, int current, int total) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current/$total',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.greyDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesSection(List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: AppTheme.headingLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.isSmallScreen(context) ? 2 : 3,
            crossAxisSpacing: AppTheme.spacingM,
            mainAxisSpacing: AppTheme.spacingM,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isEarned = achievement.isEarned;
    final progress = achievement.progressPercentage;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: isEarned 
            ? Border.all(
                color: AppTheme.greyPrimary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Achievement Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isEarned 
                    ? AppTheme.greyPrimary
                    : AppTheme.greyDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 28,
                color: isEarned 
                    ? AppTheme.primaryText
                    : AppTheme.secondaryText,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Achievement Title
            Text(
              achievement.title,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isEarned 
                    ? AppTheme.primaryText
                    : AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Achievement Description
            Text(
              achievement.description,
              style: AppTheme.caption.copyWith(
                color: isEarned 
                    ? AppTheme.secondaryText
                    : AppTheme.disabledText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Progress indicator for unearned achievements
            if (!isEarned && progress > 0) ...[
              const SizedBox(height: AppTheme.spacingS),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.greyDark,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.greyPrimary.withValues(alpha: 0.7),
                ),
                minHeight: 3,
              ),
              const SizedBox(height: 2),
              Text(
                '${(progress * 100).round()}%',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.disabledText,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}