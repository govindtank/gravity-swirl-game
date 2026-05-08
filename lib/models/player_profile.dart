import '../core/constants.dart';

// ========================================================
// PLAYER PROFILE - Persistent Player Data
// ========================================================

class PlayerProfile {
  // Stats
  int highScore;
  int highestLevel;
  int totalGamesPlayed;
  int totalGoalsCollected;
  int totalPlayTime; // seconds
  int longestCombo;

  // Unlocks
  Set<String> unlockedAchievements;
  Set<String> unlockedParticleStyles;
  Set<String> unlockedTrailEffects;
  Set<String> unlockedBackgrounds;
  Set<String> unlockedGoalStyles;

  // Selected customizations
  String selectedTheme;
  ParticleStyle selectedParticleStyle;
  TrailStyle selectedTrailEffect;
  BackgroundStyle selectedBackground;
  GoalStyle selectedGoalStyle;

  // Settings
  double soundVolume;
  double musicVolume;
  bool showFPS;
  bool hapticFeedback;

  PlayerProfile({
    required this.highScore,
    required this.highestLevel,
    required this.totalGamesPlayed,
    required this.totalGoalsCollected,
    required this.totalPlayTime,
    required this.longestCombo,
    required this.unlockedAchievements,
    required this.unlockedParticleStyles,
    required this.unlockedTrailEffects,
    required this.unlockedBackgrounds,
    required this.unlockedGoalStyles,
    required this.selectedTheme,
    required this.selectedParticleStyle,
    required this.selectedTrailEffect,
    required this.selectedBackground,
    required this.selectedGoalStyle,
    required this.soundVolume,
    required this.musicVolume,
    required this.showFPS,
    required this.hapticFeedback,
  });

  factory PlayerProfile.defaults() {
    return PlayerProfile(
      highScore: 0,
      highestLevel: 1,
      totalGamesPlayed: 0,
      totalGoalsCollected: 0,
      totalPlayTime: 0,
      longestCombo: 0,
      unlockedAchievements: {},
      unlockedParticleStyles: {'classic', 'neon'}, // Default unlocked
      unlockedTrailEffects: {'none', 'fade'}, // Default unlocked
      unlockedBackgrounds: {'staticGradient', 'animatedStars'}, // Default
      unlockedGoalStyles: {'circles', 'diamonds'}, // Default unlocked
      selectedTheme: 'cosmic_dark',
      selectedParticleStyle: ParticleStyle.classic,
      selectedTrailEffect: TrailStyle.fade,
      selectedBackground: BackgroundStyle.animatedStars,
      selectedGoalStyle: GoalStyle.circles,
      soundVolume: 0.8,
      musicVolume: 0.5,
      showFPS: false,
      hapticFeedback: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highScore': highScore,
      'highestLevel': highestLevel,
      'totalGamesPlayed': totalGamesPlayed,
      'totalGoalsCollected': totalGoalsCollected,
      'totalPlayTime': totalPlayTime,
      'longestCombo': longestCombo,
      'unlockedAchievements': unlockedAchievements.toList(),
      'unlockedParticleStyles': unlockedParticleStyles.toList(),
      'unlockedTrailEffects': unlockedTrailEffects.toList(),
      'unlockedBackgrounds': unlockedBackgrounds.toList(),
      'unlockedGoalStyles': unlockedGoalStyles.toList(),
      'selectedTheme': selectedTheme,
      'selectedParticleStyle': selectedParticleStyle.index,
      'selectedTrailEffect': selectedTrailEffect.index,
      'selectedBackground': selectedBackground.index,
      'selectedGoalStyle': selectedGoalStyle.index,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'showFPS': showFPS,
      'hapticFeedback': hapticFeedback,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      highScore: json['highScore'] ?? 0,
      highestLevel: json['highestLevel'] ?? 1,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGoalsCollected: json['totalGoalsCollected'] ?? 0,
      totalPlayTime: json['totalPlayTime'] ?? 0,
      longestCombo: json['longestCombo'] ?? 0,
      unlockedAchievements:
          Set<String>.from(json['unlockedAchievements'] ?? []),
      unlockedParticleStyles:
          Set<String>.from(json['unlockedParticleStyles'] ?? ['classic', 'neon']),
      unlockedTrailEffects:
          Set<String>.from(json['unlockedTrailEffects'] ?? ['none', 'fade']),
      unlockedBackgrounds: Set<String>.from(
          json['unlockedBackgrounds'] ?? ['staticGradient', 'animatedStars']),
      unlockedGoalStyles:
          Set<String>.from(json['unlockedGoalStyles'] ?? ['circles', 'diamonds']),
      selectedTheme: json['selectedTheme'] ?? 'cosmic_dark',
      selectedParticleStyle:
          ParticleStyle.values[json['selectedParticleStyle'] ?? 0],
      selectedTrailEffect: TrailStyle.values[json['selectedTrailEffect'] ?? 1],
      selectedBackground:
          BackgroundStyle.values[json['selectedBackground'] ?? 1],
      selectedGoalStyle: GoalStyle.values[json['selectedGoalStyle'] ?? 0],
      soundVolume: (json['soundVolume'] ?? 0.8).toDouble(),
      musicVolume: (json['musicVolume'] ?? 0.5).toDouble(),
      showFPS: json['showFPS'] ?? false,
      hapticFeedback: json['hapticFeedback'] ?? true,
    );
  }

  // Computed properties
  String get formattedPlayTime {
    final hours = totalPlayTime ~/ 3600;
    final minutes = (totalPlayTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int get achievementCount => unlockedAchievements.length;
}
