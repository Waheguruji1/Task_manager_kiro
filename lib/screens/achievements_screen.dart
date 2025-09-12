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
          // Use auto-refresh achievements provider for seamless updates
          final achievementsAsync = ref.watch(autoRefreshAchievementsProvider);
          
          return achievementsAsync.when(
            data: (achievements) {
              return RefreshIndicator(
                onRefresh: () async {
                  // Force refresh using navigation notifier for seamless updates
                  final navigationNotifier = ref.read(screenNavigationNotifierProvider.notifier);
                  navigationNotifier.navigateToAchievements();
                  
                  // Wait for the auto-refresh provider to complete
                  await ref.read(autoRefreshAchievementsProvider.future);
                },
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
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.greyPrimary,
                ),
              );
            },
            error: (error, stack) {
              return Center(
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
                      onPressed: () {
                        // Force refresh using navigation notifier
                        final navigationNotifier = ref.read(screenNavigationNotifierProvider.notifier);
                        navigationNotifier.navigateToAchievements();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressSection(List<Achievement> achievements) {
    final earnedCount = achievements.where((a) => a.isEarned).length;
    final totalCount = achievements.length;
    final progressPercentage = totalCount > 0 ? (earnedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(
          color: AppTheme.greyPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.greyPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.greyPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement Progress',
                      style: AppTheme.headingMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      'Keep completing tasks to unlock more achievements',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earned',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '$earnedCount',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.greyPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '$totalCount',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '$progressPercentage%',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.greyPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
            
            // Simple progress text for unearned achievements
            if (!isEarned && progress > 0) ...[
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                '${achievement.currentProgress}/${achievement.targetValue}',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.greyPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}