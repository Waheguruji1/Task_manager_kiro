import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/theme.dart';

/// Widget for displaying individual achievements with progress indicators
/// 
/// This widget handles both earned and unearned achievements with proper
/// visual distinction and theme integration.
class AchievementWidget extends StatelessWidget {
  final Achievement achievement;
  final bool isEarned;
  final double progress;

  const AchievementWidget({
    super.key,
    required this.achievement,
    required this.isEarned,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: _getContainerDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            _buildAchievementIcon(),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: AppTheme.spacingXS),
                  _buildDescription(),
                  if (!isEarned) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    _buildProgressIndicator(),
                  ],
                  if (isEarned && achievement.earnedAt != null) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    _buildEarnedDate(),
                  ],
                ],
              ),
            ),
            if (isEarned) _buildEarnedBadge(),
          ],
        ),
      ),
    );
  }

  /// Container decoration based on earned status
  BoxDecoration _getContainerDecoration() {
    return BoxDecoration(
      color: isEarned ? AppTheme.surfaceGrey : AppTheme.greyDark,
      borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
      border: Border.all(
        color: isEarned ? AppTheme.purplePrimary : AppTheme.borderWhite,
        width: isEarned ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Achievement icon with visual distinction for earned/unearned
  Widget _buildAchievementIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isEarned ? AppTheme.purplePrimary : AppTheme.greyPrimary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.borderWhite,
          width: 2,
        ),
      ),
      child: Icon(
        achievement.icon,
        color: AppTheme.primaryText,
        size: 24,
      ),
    );
  }

  /// Title row with achievement title
  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            achievement.title,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: isEarned ? AppTheme.primaryText : AppTheme.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  /// Achievement description and unlock criteria
  Widget _buildDescription() {
    return Text(
      achievement.description,
      style: AppTheme.bodyMedium.copyWith(
        color: isEarned ? AppTheme.secondaryText : AppTheme.disabledText,
      ),
    );
  }

  /// Progress indicator for unearned achievements
  Widget _buildProgressIndicator() {
    final progressPercentage = achievement.progressPercentage;
    final progressText = _getProgressText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTheme.caption.copyWith(
                color: AppTheme.disabledText,
              ),
            ),
            Text(
              progressText,
              style: AppTheme.caption.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.greyDark,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppTheme.borderWhite.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.purplePrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get progress text based on achievement type
  String _getProgressText() {
    final current = achievement.currentProgress;
    final target = achievement.targetValue;
    final percentage = (achievement.progressPercentage * 100).round();

    switch (achievement.type) {
      case AchievementType.streak:
        return '$current/$target days ($percentage%)';
      case AchievementType.dailyCompletion:
        return '$current/$target tasks ($percentage%)';
      case AchievementType.weeklyCompletion:
        return '$current/$target weeks ($percentage%)';
      case AchievementType.monthlyCompletion:
        return '$current/$target months ($percentage%)';
      case AchievementType.routineConsistency:
        return '$current/$target days ($percentage%)';
      case AchievementType.firstTime:
        return current >= target ? 'Complete!' : 'Not started';
    }
  }

  /// Earned date display
  Widget _buildEarnedDate() {
    if (achievement.earnedAt == null) return const SizedBox.shrink();

    final earnedDate = achievement.earnedAt!;
    final formattedDate = '${earnedDate.day}/${earnedDate.month}/${earnedDate.year}';

    return Text(
      'Earned on $formattedDate',
      style: AppTheme.caption.copyWith(
        color: AppTheme.purplePrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Earned achievement badge
  Widget _buildEarnedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.purplePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderWhite,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.primaryText,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            'Earned',
            style: AppTheme.caption.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}