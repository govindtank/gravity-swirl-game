import 'package:flutter/material.dart';

// ========================================================
// ACHIEVEMENT SYSTEM
// ========================================================

enum AchievementCategory {
  progression,
  skill,
  discovery,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final bool Function(AchievementCheckData) condition;
  bool unlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.condition,
    this.unlocked = false,
    this.unlockedAt,
  });

  void unlock() {
    if (!unlocked) {
      unlocked = true;
      unlockedAt = DateTime.now();
    }
  }
}

// Data passed to achievement condition checks
class AchievementCheckData {
  final int currentLevel;
  final int highestLevel;
  final int score;
  final int highScore;
  final int combo;
  final int longestCombo;
  final int totalGoalsCollected;
  final int goalsThisLevel;
  final int particlesLost;
  final double levelTime;
  final Set<String> encounteredObjects;
  final Set<String> usedPowerups;
  final int unlockedCustomizations;

  AchievementCheckData({
    this.currentLevel = 1,
    this.highestLevel = 1,
    this.score = 0,
    this.highScore = 0,
    this.combo = 0,
    this.longestCombo = 0,
    this.totalGoalsCollected = 0,
    this.goalsThisLevel = 0,
    this.particlesLost = 0,
    this.levelTime = 0,
    this.encounteredObjects = const {},
    this.usedPowerups = const {},
    this.unlockedCustomizations = 0,
  });
}

// ========================================================
// ACHIEVEMENT DEFINITIONS
// ========================================================

class Achievements {
  static List<Achievement> all = [
    // === PROGRESSION ===
    Achievement(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete level 1',
      icon: Icons.directions_walk,
      category: AchievementCategory.progression,
      condition: (data) => data.currentLevel >= 2,
    ),
    Achievement(
      id: 'getting_started',
      name: 'Getting Started',
      description: 'Reach level 10',
      icon: Icons.trending_up,
      category: AchievementCategory.progression,
      condition: (data) => data.highestLevel >= 10,
    ),
    Achievement(
      id: 'intermediate',
      name: 'Intermediate',
      description: 'Reach level 25',
      icon: Icons.star_half,
      category: AchievementCategory.progression,
      condition: (data) => data.highestLevel >= 25,
    ),
    Achievement(
      id: 'expert',
      name: 'Expert',
      description: 'Reach level 50',
      icon: Icons.star,
      category: AchievementCategory.progression,
      condition: (data) => data.highestLevel >= 50,
    ),
    Achievement(
      id: 'master',
      name: 'Master',
      description: 'Reach level 100',
      icon: Icons.emoji_events,
      category: AchievementCategory.progression,
      condition: (data) => data.highestLevel >= 100,
    ),
    Achievement(
      id: 'score_1k',
      name: 'Point Collector',
      description: 'Score 1,000 points in a single game',
      icon: Icons.looks_one,
      category: AchievementCategory.progression,
      condition: (data) => data.score >= 1000,
    ),
    Achievement(
      id: 'score_10k',
      name: 'Point Master',
      description: 'Score 10,000 points in a single game',
      icon: Icons.looks_two,
      category: AchievementCategory.progression,
      condition: (data) => data.score >= 10000,
    ),

    // === SKILL ===
    Achievement(
      id: 'combo_starter',
      name: 'Combo Starter',
      description: 'Get a 5x combo',
      icon: Icons.flash_on,
      category: AchievementCategory.skill,
      condition: (data) => data.longestCombo >= 5,
    ),
    Achievement(
      id: 'combo_pro',
      name: 'Combo Pro',
      description: 'Get a 10x combo',
      icon: Icons.bolt,
      category: AchievementCategory.skill,
      condition: (data) => data.longestCombo >= 10,
    ),
    Achievement(
      id: 'combo_master',
      name: 'Combo Master',
      description: 'Get a 15x combo',
      icon: Icons.offline_bolt,
      category: AchievementCategory.skill,
      condition: (data) => data.longestCombo >= 15,
    ),
    Achievement(
      id: 'perfect_level',
      name: 'Perfect Level',
      description: 'Complete a level without losing any particles',
      icon: Icons.verified,
      category: AchievementCategory.skill,
      condition: (data) => data.particlesLost == 0 && data.goalsThisLevel > 0,
    ),
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete a level in under 10 seconds',
      icon: Icons.speed,
      category: AchievementCategory.skill,
      condition: (data) => data.levelTime > 0 && data.levelTime < 10,
    ),
    Achievement(
      id: 'collector_100',
      name: 'Goal Collector',
      description: 'Collect 100 total goals',
      icon: Icons.collections,
      category: AchievementCategory.skill,
      condition: (data) => data.totalGoalsCollected >= 100,
    ),
    Achievement(
      id: 'collector_1000',
      name: 'Goal Hoarder',
      description: 'Collect 1,000 total goals',
      icon: Icons.collections_bookmark,
      category: AchievementCategory.skill,
      condition: (data) => data.totalGoalsCollected >= 1000,
    ),

    // === DISCOVERY ===
    Achievement(
      id: 'discover_orbiting',
      name: 'Orbital Mechanics',
      description: 'Encounter an Orbiting Object',
      icon: Icons.motion_photos_on,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('orbitingObject'),
    ),
    Achievement(
      id: 'discover_pulsing',
      name: 'Pulse Rider',
      description: 'Encounter a Pulsing Object',
      icon: Icons.waves,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('pulsingObject'),
    ),
    Achievement(
      id: 'discover_teleporter',
      name: 'Space Folder',
      description: 'Use a Teleporter',
      icon: Icons.swap_calls,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('teleporter'),
    ),
    Achievement(
      id: 'discover_splitter',
      name: 'Particle Duplicator',
      description: 'Use a Splitter',
      icon: Icons.call_split,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('splitter'),
    ),
    Achievement(
      id: 'discover_magnetic',
      name: 'Magnetic Personality',
      description: 'Enter a Magnetic Field',
      icon: Icons.compass_calibration,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('magneticField'),
    ),
    Achievement(
      id: 'discover_blackhole',
      name: 'Event Horizon',
      description: 'Survive near a Black Hole',
      icon: Icons.blur_on,
      category: AchievementCategory.discovery,
      condition: (data) => data.encounteredObjects.contains('blackHole'),
    ),
    Achievement(
      id: 'powerup_shield',
      name: 'Protected',
      description: 'Collect a Shield powerup',
      icon: Icons.shield,
      category: AchievementCategory.discovery,
      condition: (data) => data.usedPowerups.contains('shield'),
    ),
    Achievement(
      id: 'powerup_multiplier',
      name: 'Double Trouble',
      description: 'Collect a 2x Multiplier powerup',
      icon: Icons.looks_two,
      category: AchievementCategory.discovery,
      condition: (data) => data.usedPowerups.contains('multiplier'),
    ),
    Achievement(
      id: 'powerup_slowmo',
      name: 'Time Bender',
      description: 'Collect a Slow Motion powerup',
      icon: Icons.hourglass_bottom,
      category: AchievementCategory.discovery,
      condition: (data) => data.usedPowerups.contains('slowMotion'),
    ),
    Achievement(
      id: 'customizer',
      name: 'Customizer',
      description: 'Unlock 5 customization items',
      icon: Icons.palette,
      category: AchievementCategory.discovery,
      condition: (data) => data.unlockedCustomizations >= 5,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  static int get totalCount => all.length;

  static int unlockedCount(Set<String> unlockedIds) {
    return all.where((a) => unlockedIds.contains(a.id)).length;
  }
}
