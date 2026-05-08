// ========================================================
// GAME CONSTANTS & DIFFICULTY CURVES
// ========================================================

class GameConstants {
  // Physics
  static const double baseGravityStrength = 1.5;
  static const double particleDamping = 0.95;
  static const double pathInfluence = 0.0067; // 1/150
  static const double repulsionStrength = 3.0;
  static const double dt = 0.016; // 60 FPS

  // Particles
  static const int baseParticleCount = 60;
  static const double minParticleRadius = 3.0;
  static const double maxParticleRadius = 5.0;

  // Goals
  static const double goalCollectionRadius = 40.0;
  static const int baseGoalValue = 10;

  // Combo System
  static const double comboWindow = 2.0; // seconds
  static const int maxComboMultiplier = 10;

  // Powerups
  static const double powerupSpawnIntervalMin = 15.0;
  static const double powerupSpawnIntervalMax = 30.0;
  static const double powerupCollectionRadius = 35.0;

  // Trail
  static const int maxTrailLength = 15;
  static const double trailOpacity = 0.6;

  // Path
  static const int maxPathPoints = 50;
  static const double pathFadeDuration = 2.0;

  // Animations
  static const Duration levelTransitionDuration = Duration(milliseconds: 800);
  static const Duration scorePopDuration = Duration(milliseconds: 300);
  static const Duration comboPopDuration = Duration(milliseconds: 200);
}

class DifficultyScaling {
  // Gravity wells: start at 3, max 10
  static int getGravityWellCount(int level) => (3 + (level ~/ 5)).clamp(3, 10);

  // Goals: start at 3, max 15
  static int getGoalCount(int level) => (3 + (level ~/ 3)).clamp(3, 15);

  // Hazards: start at 0, max 8
  static int getHazardCount(int level) => ((level - 1) ~/ 4).clamp(0, 8);

  // Object speed multiplier: 1.0 to 3.0
  static double getSpeedMultiplier(int level) =>
      (1.0 + (level * 0.05)).clamp(1.0, 3.0);

  // Particle count: scales down slightly at high levels for performance
  static int getParticleCount(int level) =>
      (GameConstants.baseParticleCount - (level ~/ 20) * 5)
          .clamp(40, GameConstants.baseParticleCount);

  // Object types available at each level
  static List<ObjectType> getAvailableObjects(int level) {
    return [
      ObjectType.gravityWell, // Always
      if (level >= 3) ObjectType.repulsionZone,
      if (level >= 5) ObjectType.orbitingObject,
      if (level >= 8) ObjectType.pulsingObject,
      if (level >= 12) ObjectType.teleporter,
      if (level >= 15) ObjectType.splitter,
      if (level >= 20) ObjectType.magneticField,
      if (level >= 25) ObjectType.blackHole,
    ];
  }

  // Level completion bonus
  static int getLevelBonus(int level) => 100 + (level * 25);

  // Time bonus threshold (seconds)
  static double getTimeBonusThreshold(int level) =>
      (15.0 + level * 0.5).clamp(15.0, 45.0);
}

enum ObjectType {
  gravityWell,
  repulsionZone,
  orbitingObject,
  pulsingObject,
  teleporter,
  splitter,
  magneticField,
  blackHole,
}

enum PowerupType {
  shield,
  multiplier,
  slowMotion,
  magnet,
  particleBurst,
}

enum ParticleStyle {
  classic,
  neon,
  stars,
  bubbles,
  fire,
  ice,
}

enum TrailStyle {
  none,
  fade,
  rainbow,
  sparkle,
  comet,
}

enum BackgroundStyle {
  staticGradient,
  animatedStars,
  nebulaClouds,
  gridPattern,
  waveAnimation,
}

enum GoalStyle {
  circles,
  diamonds,
  stars,
  crystals,
  orbs,
}
