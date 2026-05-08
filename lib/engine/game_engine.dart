import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/game_objects.dart';
import 'level_generator.dart';

// ========================================================
// COMBO SYSTEM
// ========================================================

class ComboSystem {
  int currentCombo = 0;
  double comboTimer = 0;
  int longestCombo = 0;

  double calculateMultiplier() {
    if (currentCombo < 5) {
      return 1 + (currentCombo * 0.5);
    }
    return 3 + (currentCombo - 5) * 0.5;
  }

  int calculateScore(int baseValue) {
    return (baseValue * calculateMultiplier()).round();
  }

  void onGoalCollected() {
    currentCombo++;
    comboTimer = GameConstants.comboWindow;
    if (currentCombo > longestCombo) {
      longestCombo = currentCombo;
    }
  }

  void update(double dt) {
    if (currentCombo > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        currentCombo = 0;
      }
    }
  }

  void reset() {
    currentCombo = 0;
    comboTimer = 0;
  }
}

// ========================================================
// ACTIVE POWERUP STATE
// ========================================================

class ActivePowerup {
  final PowerupType type;
  double remainingTime;

  ActivePowerup({required this.type, required this.remainingTime});

  bool get isExpired => remainingTime <= 0;
}

// ========================================================
// GAME STATE - Enhanced
// ========================================================

class GameState {
  int score = 0;
  int currentLevel = 1;
  Color backgroundColor = const Color(0xFF0A0A2A);
  double levelTime = 0;
  int goalsCollectedThisLevel = 0;
  int particlesLostThisLevel = 0;
  bool isPaused = false;
  bool isGameOver = false;
  bool isLevelComplete = false;
  bool isTransitioning = false;

  // Combo
  ComboSystem combo = ComboSystem();

  // Active powerups
  List<ActivePowerup> activePowerups = [];

  // Game objects
  LevelData? levelData;
  List<Powerup> powerups = [];
  double powerupSpawnTimer = 0;

  // Path drawing
  List<Offset> pathPoints = [];

  // Screen shake
  double shakeIntensity = 0;
  double shakeDuration = 0;

  // Stats tracking
  Set<String> encounteredObjects = {};
  Set<String> usedPowerups = {};

  // Particles accessor
  List<Particle> get particles => levelData?.particles ?? [];

  // Goals accessor
  List<GoalMarker> get goals => levelData?.goals ?? [];

  // Check powerup status
  bool hasPowerup(PowerupType type) {
    return activePowerups.any((p) => p.type == type && !p.isExpired);
  }

  double getTimeScale() {
    if (hasPowerup(PowerupType.slowMotion)) {
      return 0.5;
    }
    return 1.0;
  }

  double getScoreMultiplier() {
    double mult = 1.0;
    if (hasPowerup(PowerupType.multiplier)) {
      mult *= 2.0;
    }
    return mult * combo.calculateMultiplier();
  }

  void triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    shakeIntensity = intensity;
    shakeDuration = duration;
  }
}

// ========================================================
// GAME ENGINE - Core Physics & Logic
// ========================================================

class GravitySwirlGameEngine extends ChangeNotifier {
  GameState state = GameState();
  final LevelGenerator _levelGenerator = LevelGenerator();
  final Random _random = Random();

  // Callbacks
  VoidCallback? onLevelComplete;
  VoidCallback? onGameOver;
  Function(String achievementId)? onAchievementUnlocked;
  Function(PowerupType type)? onPowerupCollected;
  Function(int combo)? onComboMilestone;

  void startGame({required Size gameSize}) {
    state = GameState();
    loadLevel(1, gameSize: gameSize);
  }

  void loadLevel(int level, {required Size gameSize}) {
    state.currentLevel = level;
    state.levelData = _levelGenerator.generateLevel(level, gameSize);
    state.backgroundColor = state.levelData!.backgroundColor;
    state.levelTime = 0;
    state.goalsCollectedThisLevel = 0;
    state.particlesLostThisLevel = 0;
    state.isLevelComplete = false;
    state.isTransitioning = false;
    state.powerups.clear();
    state.powerupSpawnTimer =
        GameConstants.powerupSpawnIntervalMin +
        _random.nextDouble() *
            (GameConstants.powerupSpawnIntervalMax -
                GameConstants.powerupSpawnIntervalMin);

    // Track encountered objects
    state.encounteredObjects.addAll(state.levelData!.presentObjectTypes);

    // Reset splitters
    for (final splitter in state.levelData!.splitters) {
      splitter.resetSplits();
    }

    notifyListeners();
  }

  void update(double dt, Size gameSize) {
    if (state.isPaused || state.isGameOver || state.isTransitioning) return;

    final timeScale = state.getTimeScale();
    final scaledDt = dt * timeScale;

    // Update level time
    state.levelTime += scaledDt;

    // Update combo
    state.combo.update(scaledDt);

    // Update screen shake
    if (state.shakeDuration > 0) {
      state.shakeDuration -= dt;
      if (state.shakeDuration <= 0) {
        state.shakeIntensity = 0;
      }
    }

    // Update active powerups
    _updatePowerups(scaledDt);

    // Update game objects
    _updateGameObjects(scaledDt);

    // Update particles
    _updateParticles(scaledDt, gameSize);

    // Spawn powerups
    _spawnPowerups(scaledDt, gameSize);

    // Update powerup collectibles
    _updatePowerupCollectibles(scaledDt);

    // Check goal collection
    _checkGoalCollection();

    // Check win condition
    _checkWinCondition(gameSize);

    notifyListeners();
  }

  void _updatePowerups(double dt) {
    for (final powerup in state.activePowerups) {
      powerup.remainingTime -= dt;
    }
    state.activePowerups.removeWhere((p) => p.isExpired);
  }

  void _updateGameObjects(double dt) {
    if (state.levelData == null) return;

    // Update all dynamic objects
    for (final obj in state.levelData!.orbitingObjects) {
      obj.update(dt);
    }
    for (final obj in state.levelData!.pulsingObjects) {
      obj.update(dt);
    }
    for (final obj in state.levelData!.teleporters) {
      obj.update(dt);
    }
    for (final obj in state.levelData!.splitters) {
      obj.update(dt);
    }
    for (final obj in state.levelData!.blackHoles) {
      obj.update(dt);
    }
    for (final obj in state.levelData!.gravityWells) {
      obj.update(dt);
    }

    // Update goals
    for (final goal in state.goals) {
      goal.update(dt);

      // Magnet powerup: attract goals to particles
      if (state.hasPowerup(PowerupType.magnet)) {
        goal.attractionStrength = 0.5;
        _attractGoalToParticles(goal, dt);
      } else {
        goal.attractionStrength = 0;
      }
    }
  }

  void _attractGoalToParticles(GoalMarker goal, double dt) {
    if (goal.collected || state.particles.isEmpty) return;

    // Find nearest particle
    Offset? nearestPos;
    double nearestDist = double.infinity;

    for (final particle in state.particles) {
      final dist = (particle.position - goal.position).distance;
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestPos = particle.position;
      }
    }

    if (nearestPos != null && nearestDist < 200) {
      final direction = nearestPos - goal.position;
      goal.position += direction / nearestDist * goal.attractionStrength * dt * 60;
    }
  }

  void _updateParticles(double dt, Size gameSize) {
    if (state.levelData == null) return;

    final particlesToAdd = <Particle>[];
    final particlesToRemove = <Particle>[];

    for (final particle in state.particles) {
      Offset totalForce = Offset.zero;

      // Gravity well forces
      for (final well in state.levelData!.gravityWells) {
        totalForce += well.calculateForce(particle);
      }

      // Orbiting object forces
      for (final obj in state.levelData!.orbitingObjects) {
        totalForce += obj.calculateForce(particle);
      }

      // Pulsing object forces
      for (final obj in state.levelData!.pulsingObjects) {
        totalForce += obj.calculateForce(particle);
      }

      // Repulsion zone forces
      for (final zone in state.levelData!.repulsionZones) {
        totalForce += zone.calculateForce(particle);
      }

      // Magnetic field forces
      for (final field in state.levelData!.magneticFields) {
        totalForce += field.calculateForce(particle);
      }

      // Black hole forces
      for (final hole in state.levelData!.blackHoles) {
        totalForce += hole.calculateForce(particle);

        // Check destruction
        if (hole.shouldDestroy(particle)) {
          particlesToRemove.add(particle);
          state.particlesLostThisLevel++;
          state.triggerScreenShake(intensity: 3, duration: 0.15);
        }
      }

      // Path influence
      if (state.pathPoints.isNotEmpty) {
        final lastPoint = state.pathPoints.last;
        final toPath = lastPoint - particle.position;
        totalForce += Offset(
          toPath.dx * GameConstants.pathInfluence,
          toPath.dy * GameConstants.pathInfluence,
        );
      }

      // Apply physics
      particle.velocity =
          particle.velocity * GameConstants.particleDamping + totalForce * dt;
      particle.position = particle.position + particle.velocity * dt;

      // Update trail
      particle.updateTrail();

      // Boundary clamping
      particle.position = Offset(
        particle.position.dx.clamp(-5, gameSize.width + 5),
        particle.position.dy.clamp(-5, gameSize.height + 5),
      );

      // Teleporter check
      for (final teleporter in state.levelData!.teleporters) {
        if (teleporter.shouldTeleport(particle)) {
          particle.position = teleporter.getTeleportDestination();
          teleporter.triggerCooldown();
          particle.clearTrail();
          state.encounteredObjects.add('teleporter');
        }
      }

      // Splitter check
      for (final splitter in state.levelData!.splitters) {
        if (splitter.shouldSplit(particle)) {
          particlesToAdd.add(splitter.createSplitParticle(particle));
          splitter.triggerSplit();
          state.encounteredObjects.add('splitter');
        }
      }
    }

    // Apply particle changes
    state.particles.removeWhere((p) => particlesToRemove.contains(p));
    state.particles.addAll(particlesToAdd);

    // Shield protection
    if (state.hasPowerup(PowerupType.shield)) {
      for (final particle in state.particles) {
        particle.isShielded = true;
      }
    } else {
      for (final particle in state.particles) {
        particle.isShielded = false;
      }
    }
  }

  void _spawnPowerups(double dt, Size gameSize) {
    state.powerupSpawnTimer -= dt;

    if (state.powerupSpawnTimer <= 0) {
      // Spawn a powerup
      final types = PowerupType.values;
      final type = types[_random.nextInt(types.length)];

      state.powerups.add(Powerup(
        position: Offset(
          50 + _random.nextDouble() * (gameSize.width - 100),
          50 + _random.nextDouble() * (gameSize.height - 100),
        ),
        type: type,
        duration: Powerup.getDuration(type),
      ));

      // Reset timer
      state.powerupSpawnTimer =
          GameConstants.powerupSpawnIntervalMin +
          _random.nextDouble() *
              (GameConstants.powerupSpawnIntervalMax -
                  GameConstants.powerupSpawnIntervalMin);
    }
  }

  void _updatePowerupCollectibles(double dt) {
    final toRemove = <Powerup>[];

    for (final powerup in state.powerups) {
      powerup.update(dt);

      if (powerup.isExpired()) {
        toRemove.add(powerup);
        continue;
      }

      // Check collection
      for (final particle in state.particles) {
        if (powerup.checkCollection(particle.position) && !powerup.collected) {
          powerup.collected = true;
          _collectPowerup(powerup);
          toRemove.add(powerup);
          break;
        }
      }
    }

    state.powerups.removeWhere((p) => toRemove.contains(p));
  }

  void _collectPowerup(Powerup powerup) {
    state.usedPowerups.add(powerup.type.name);

    if (powerup.type == PowerupType.particleBurst) {
      // Instant effect: add particles
      _addBurstParticles();
    } else {
      // Duration effect
      state.activePowerups.add(ActivePowerup(
        type: powerup.type,
        remainingTime: powerup.duration,
      ));
    }

    onPowerupCollected?.call(powerup.type);
    state.triggerScreenShake(intensity: 2, duration: 0.1);
  }

  void _addBurstParticles() {
    if (state.levelData == null) return;

    final existing = state.particles;
    if (existing.isEmpty) return;

    // Add particles around existing ones
    for (int i = 0; i < 20 && state.particles.length < 100; i++) {
      final source = existing[_random.nextInt(existing.length)];
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 2 + _random.nextDouble() * 3;

      state.particles.add(Particle(
        position: source.position + Offset(cos(angle) * 10, sin(angle) * 10),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        radius: GameConstants.minParticleRadius +
            _random.nextDouble() *
                (GameConstants.maxParticleRadius - GameConstants.minParticleRadius),
      ));
    }
  }

  void _checkGoalCollection() {
    for (final goal in state.goals) {
      if (!goal.collected) {
        for (final particle in state.particles) {
          if (goal.checkCollection(particle.position)) {
            goal.collected = true;
            final baseScore = goal.value;
            final finalScore =
                (baseScore * state.getScoreMultiplier()).round();
            state.score += finalScore;
            state.goalsCollectedThisLevel++;
            state.combo.onGoalCollected();

            // Check combo milestones
            if (state.combo.currentCombo == 5 ||
                state.combo.currentCombo == 10 ||
                state.combo.currentCombo == 15) {
              onComboMilestone?.call(state.combo.currentCombo);
            }

            state.triggerScreenShake(intensity: 2, duration: 0.1);
            break;
          }
        }
      }
    }
  }

  void _checkWinCondition(Size gameSize) {
    if (state.goals.every((g) => g.collected) && !state.isLevelComplete) {
      state.isLevelComplete = true;
      state.isTransitioning = true;

      // Level complete bonus
      int bonus = DifficultyScaling.getLevelBonus(state.currentLevel);
      if (state.particlesLostThisLevel == 0) {
        bonus = (bonus * 1.5).round(); // Perfect bonus
      }
      state.score += bonus;

      onLevelComplete?.call();

      // Transition to next level after delay
      Future.delayed(GameConstants.levelTransitionDuration, () {
        loadLevel(state.currentLevel + 1, gameSize: gameSize);
      });
    }
  }

  // ========== Input Handlers ==========

  void addPathPoint(Offset point) {
    state.pathPoints.add(point);
    if (state.pathPoints.length > GameConstants.maxPathPoints) {
      state.pathPoints.removeAt(0);
    }
  }

  void clearPath() {
    state.pathPoints.clear();
  }

  void scheduleClearPath() {
    Future.delayed(const Duration(seconds: 2), () {
      clearPath();
      notifyListeners();
    });
  }

  // ========== Game Control ==========

  void pause() {
    state.isPaused = true;
    notifyListeners();
  }

  void resume() {
    state.isPaused = false;
    notifyListeners();
  }

  void gameOver() {
    state.isGameOver = true;
    onGameOver?.call();
    notifyListeners();
  }

  void restart(Size gameSize) {
    startGame(gameSize: gameSize);
  }
}
