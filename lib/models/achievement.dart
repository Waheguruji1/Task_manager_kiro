import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  dailyCompletion,
  weeklyCompletion,
  monthlyCompletion,
  routineConsistency,
  firstTime,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementType type;
  final int targetValue;
  final bool isEarned;
  final DateTime? earnedAt;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    this.isEarned = false,
    this.earnedAt,
    this.currentProgress = 0,
  });

  double get progressPercentage =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    AchievementType? type,
    int? targetValue,
    bool? isEarned,
    DateTime? earnedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'type': type.index,
      'targetValue': targetValue,
      'isEarned': isEarned,
      'earnedAt': earnedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      type: AchievementType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      isEarned: json['isEarned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null 
          ? DateTime.parse(json['earnedAt'] as String)
          : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, isEarned: $isEarned, progress: $currentProgress/$targetValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}