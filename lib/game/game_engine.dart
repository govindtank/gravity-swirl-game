import 'dart:math';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// COSMIC DRIFT - Game Engine
// ══════════════════════════════════════════════════════════════

enum GameStatus { menu, playing, paused, levelComplete, gameOver }

// ── Level Objects ──

class GravityWell {
  final Offset position;
  final double strength;
  final double visualRadius;
  final Color color;
  final Color glowColor;

  GravityWell({
    required this.position,
    this.strength = 1.0,
    this.visualRadius = 30,
    this.color = const Color(0xFFFF6B35),
    this.glowColor = const Color(0xFFFF9800),
  });

  Offset getForce(Offset shipPos, double shipMass) {
    final delta = position - shipPos;
    final dist = delta.distance.clamp(10.0, double.infinity);
    final forceMag = strength * shipMass / (dist * dist);
    return delta / dist * forceMag;
  }
}

class BlackHole {
  final Offset position;
  final double radius;
  final double eventHorizon;

  BlackHole({
    required this.position,
    this.radius = 35,
    this.eventHorizon = 18,
  });

  bool consumes(Offset shipPos) {
    return (shipPos - position).distance < eventHorizon;
  }

  Offset getForce(Offset shipPos, double shipMass) {
    final delta = position - shipPos;
    final dist = delta.distance.clamp(15.0, double.infinity);
    final forceMag = 3.0 * shipMass / (dist * dist);
    return delta / dist * forceMag;
  }
}

class Star {
  final Offset position;
  bool collected = false;
  double animTime = 0;

  Star({required this.position});

  bool checkCollection(Offset shipPos, double collectRadius) {
    if (collected) return false;
    if ((shipPos - position).distance < collectRadius) {
      collected = true;
      return true;
    }
    return false;
  }
}

class Portal {
  final Offset position;
  final double radius;
  bool active = false;

  Portal({required this.position, this.radius = 25});

  bool checkReached(Offset shipPos) {
    if (!active) return false;
    return (shipPos - position).distance < radius;
  }
}

// ── Ship ──

class Ship {
  Offset position;
  Offset velocity = Offset.zero;
  final List<Offset> trail = [];
  bool alive = true;
  bool reachedPortal = false;
  double thrustX = 0;
  double thrustY = 0;
  bool thrusting = false;

  Ship({required this.position});

  void applyThrust(double dx, double dy) {
    thrustX = dx;
    thrustY = dy;
    thrusting = true;
  }

  void clearThrust() {
    thrusting = false;
    thrustX = 0;
    thrustY = 0;
  }

  void updateTrail() {
    trail.add(position);
    if (trail.length > 25) trail.removeAt(0);
  }

  void clearTrail() => trail.clear();

  void reset(Offset startPos) {
    position = startPos;
    velocity = Offset.zero;
    alive = true;
    reachedPortal = false;
    clearTrail();
    clearThrust();
  }
}

// ── Particles (cosmetic) ──

class CosmoParticle {
  double x, y, vx, vy, lifetime, maxLifetime, radius;
  final Color color;
  bool dead = false;

  CosmoParticle({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.maxLifetime = 1.0,
    this.radius = 2,
    this.color = Colors.white,
  }) : lifetime = 0;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 200 * dt;
    lifetime += dt;
    if (lifetime >= maxLifetime) dead = true;
  }

  double get progress => lifetime / maxLifetime;
}

// ── Level Generation ──

class LevelDefinition {
  final int levelNumber;
  final String name;
  final Offset startPos; // normalized 0-1
  final Offset exitPos;
  final List<({Offset pos, double strength, double visualRadius, Color color, Color glowColor})> wells;
  final List<Offset> starPositions;
  final List<Offset> blackHolePositions;
  final Color bgColor;
  final Color accentColor;

  const LevelDefinition({
    required this.levelNumber,
    required this.name,
    required this.startPos,
    required this.exitPos,
    this.wells = const [],
    this.starPositions = const [],
    this.blackHolePositions = const [],
    this.bgColor = const Color(0xFF0A0A1A),
    this.accentColor = const Color(0xFF00E5FF),
  });
}

// ══════════════════════════════════════════════════════════════
// 15 CURATED LEVELS
// ══════════════════════════════════════════════════════════════

final List<LevelDefinition> cosmicLevels = [
  // Level 1 - First Flight
  LevelDefinition(
    levelNumber: 1,
    name: 'First Flight',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.3, 0.5), Offset(0.55, 0.5), Offset(0.8, 0.5),
    ],
    wells: [],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFF00E5FF),
  ),

  // Level 2 - Gentle Curve
  LevelDefinition(
    levelNumber: 2,
    name: 'Gentle Curve',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.85, 0.8),
    starPositions: [
      Offset(0.3, 0.4), Offset(0.55, 0.35), Offset(0.75, 0.7),
    ],
    wells: [
      (pos: Offset(0.5, 0.65), strength: 1.2, visualRadius: 28, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFF6B35),
  ),

  // Level 3 - Slingshot
  LevelDefinition(
    levelNumber: 3,
    name: 'Slingshot',
    startPos: Offset(0.1, 0.3),
    exitPos: Offset(0.9, 0.3),
    starPositions: [
      Offset(0.35, 0.5), Offset(0.5, 0.65), Offset(0.7, 0.45),
    ],
    wells: [
      (pos: Offset(0.5, 0.7), strength: 2.0, visualRadius: 35, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFF9800),
  ),

  // Level 4 - Binary Stars
  LevelDefinition(
    levelNumber: 4,
    name: 'Binary Stars',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.25, 0.5), Offset(0.4, 0.7), Offset(0.65, 0.35), Offset(0.8, 0.5),
    ],
    wells: [
      (pos: Offset(0.35, 0.3), strength: 1.5, visualRadius: 30, color: Color(0xFF00BCD4), glowColor: Color(0xFF00E5FF)),
      (pos: Offset(0.65, 0.7), strength: 1.5, visualRadius: 30, color: Color(0xFFFF4081), glowColor: Color(0xFFFF80AB)),
    ],
    bgColor: Color(0xFF0D0A1A),
    accentColor: Color(0xFF00BCD4),
  ),

  // Level 5 - Triangle
  LevelDefinition(
    levelNumber: 5,
    name: 'The Triangle',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.3, 0.3), Offset(0.5, 0.5), Offset(0.7, 0.7),
    ],
    wells: [
      (pos: Offset(0.5, 0.2), strength: 1.8, visualRadius: 32, color: Color(0xFF7C4DFF), glowColor: Color(0xFFB388FF)),
      (pos: Offset(0.3, 0.8), strength: 1.8, visualRadius: 32, color: Color(0xFF448AFF), glowColor: Color(0xFF82B1FF)),
      (pos: Offset(0.7, 0.8), strength: 1.8, visualRadius: 32, color: Color(0xFFFF4081), glowColor: Color(0xFFFF80AB)),
    ],
    bgColor: Color(0xFF0D0A1A),
    accentColor: Color(0xFF7C4DFF),
  ),

  // Level 6 - The Long Haul
  LevelDefinition(
    levelNumber: 6,
    name: 'The Long Haul',
    startPos: Offset(0.08, 0.5),
    exitPos: Offset(0.92, 0.5),
    starPositions: [
      Offset(0.2, 0.4), Offset(0.4, 0.6), Offset(0.6, 0.35), Offset(0.8, 0.55),
    ],
    wells: [
      (pos: Offset(0.2, 0.6), strength: 1.2, visualRadius: 25, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
      (pos: Offset(0.4, 0.35), strength: 1.5, visualRadius: 28, color: Color(0xFF00BCD4), glowColor: Color(0xFF00E5FF)),
      (pos: Offset(0.6, 0.65), strength: 1.5, visualRadius: 28, color: Color(0xFFFF4081), glowColor: Color(0xFFFF80AB)),
      (pos: Offset(0.8, 0.4), strength: 1.0, visualRadius: 22, color: Color(0xFF76FF03), glowColor: Color(0xFFB2FF59)),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFF00E5FF),
  ),

  // Level 7 - Zigzag
  LevelDefinition(
    levelNumber: 7,
    name: 'Zigzag',
    startPos: Offset(0.1, 0.15),
    exitPos: Offset(0.9, 0.85),
    starPositions: [
      Offset(0.3, 0.3), Offset(0.5, 0.5), Offset(0.7, 0.7),
    ],
    wells: [
      (pos: Offset(0.3, 0.7), strength: 2.0, visualRadius: 30, color: Color(0xFF7C4DFF), glowColor: Color(0xFFB388FF)),
      (pos: Offset(0.7, 0.3), strength: 2.0, visualRadius: 30, color: Color(0xFFFF4081), glowColor: Color(0xFFFF80AB)),
    ],
    bgColor: Color(0xFF0D0A1A),
    accentColor: Color(0xFF7C4DFF),
  ),

  // Level 8 - The Vortex (first black hole)
  LevelDefinition(
    levelNumber: 8,
    name: 'The Vortex',
    startPos: Offset(0.1, 0.3),
    exitPos: Offset(0.9, 0.7),
    starPositions: [
      Offset(0.3, 0.5), Offset(0.55, 0.45), Offset(0.75, 0.65),
    ],
    wells: [
      (pos: Offset(0.5, 0.5), strength: 2.5, visualRadius: 38, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
    ],
    blackHolePositions: [
      Offset(0.35, 0.65),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFF6B35),
  ),

  // Level 9 - Precision
  LevelDefinition(
    levelNumber: 9,
    name: 'Precision',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.3, 0.25), Offset(0.5, 0.5), Offset(0.7, 0.75),
    ],
    wells: [
      (pos: Offset(0.4, 0.5), strength: 2.2, visualRadius: 32, color: Color(0xFF00BCD4), glowColor: Color(0xFF00E5FF)),
      (pos: Offset(0.6, 0.5), strength: 2.2, visualRadius: 32, color: Color(0xFF00BCD4), glowColor: Color(0xFF00E5FF)),
    ],
    blackHolePositions: [
      Offset(0.25, 0.45), Offset(0.75, 0.55),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFF00BCD4),
  ),

  // Level 10 - Crossroads
  LevelDefinition(
    levelNumber: 10,
    name: 'Crossroads',
    startPos: Offset(0.5, 0.08),
    exitPos: Offset(0.5, 0.92),
    starPositions: [
      Offset(0.3, 0.5), Offset(0.5, 0.4), Offset(0.7, 0.5),
    ],
    wells: [
      (pos: Offset(0.3, 0.6), strength: 1.8, visualRadius: 30, color: Color(0xFF7C4DFF), glowColor: Color(0xFFB388FF)),
      (pos: Offset(0.7, 0.6), strength: 1.8, visualRadius: 30, color: Color(0xFF7C4DFF), glowColor: Color(0xFFB388FF)),
      (pos: Offset(0.5, 0.35), strength: 1.5, visualRadius: 28, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
    ],
    bgColor: Color(0xFF0D0A1A),
    accentColor: Color(0xFF7C4DFF),
  ),

  // Level 11 - The Ring
  LevelDefinition(
    levelNumber: 11,
    name: 'The Ring',
    startPos: Offset(0.5, 0.08),
    exitPos: Offset(0.5, 0.92),
    starPositions: [
      Offset(0.5, 0.25), Offset(0.35, 0.5), Offset(0.65, 0.5), Offset(0.5, 0.75),
    ],
    wells: List.generate(6, (i) {
      final angle = (i / 6) * 2 * pi;
      final r = 0.25;
      return (
        pos: Offset(0.5 + cos(angle) * r, 0.5 + sin(angle) * r),
        strength: 1.2,
        visualRadius: 20,
        color: Color.lerp(const Color(0xFFFF6B35), const Color(0xFFFF4081), i / 6)!,
        glowColor: Color.lerp(const Color(0xFFFF9800), const Color(0xFFFF80AB), i / 6)!,
      );
    }),
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFF6B35),
  ),

  // Level 12 - Gravity Maze
  LevelDefinition(
    levelNumber: 12,
    name: 'Gravity Maze',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.25, 0.35), Offset(0.45, 0.65), Offset(0.65, 0.3), Offset(0.8, 0.6),
    ],
    wells: [
      (pos: Offset(0.2, 0.5), strength: 1.5, visualRadius: 26, color: Color(0xFFFF6B35), glowColor: Color(0xFFFF9800)),
      (pos: Offset(0.4, 0.35), strength: 1.8, visualRadius: 28, color: Color(0xFF00E5FF), glowColor: Color(0xFF69F0AE)),
      (pos: Offset(0.6, 0.65), strength: 1.8, visualRadius: 28, color: Color(0xFFFF4081), glowColor: Color(0xFFFF80AB)),
      (pos: Offset(0.8, 0.5), strength: 1.5, visualRadius: 26, color: Color(0xFF7C4DFF), glowColor: Color(0xFFB388FF)),
    ],
    bgColor: Color(0xFF0D0A1A),
    accentColor: Color(0xFF00E5FF),
  ),

  // Level 13 - Star Cluster
  LevelDefinition(
    levelNumber: 13,
    name: 'Star Cluster',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: List.generate(7, (i) {
      final angle = (i / 7) * 2 * pi;
      return Offset(0.5 + cos(angle) * 0.15, 0.5 + sin(angle) * 0.15);
    }),
    wells: [
      (pos: Offset(0.5, 0.5), strength: 2.0, visualRadius: 34, color: Color(0xFFFFD700), glowColor: Color(0xFFFFF176)),
    ],
    blackHolePositions: [
      Offset(0.35, 0.3), Offset(0.65, 0.7),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFFD700),
  ),

  // Level 14 - The Void
  LevelDefinition(
    levelNumber: 14,
    name: 'The Void',
    startPos: Offset(0.1, 0.5),
    exitPos: Offset(0.9, 0.5),
    starPositions: [
      Offset(0.3, 0.5), Offset(0.5, 0.3), Offset(0.5, 0.7), Offset(0.7, 0.5),
    ],
    wells: [],
    blackHolePositions: [
      Offset(0.4, 0.5), Offset(0.6, 0.5),
    ],
    bgColor: Color(0xFF050510),
    accentColor: Color(0xFF76FF03),
  ),

  // Level 15 - Cosmic Convergence
  LevelDefinition(
    levelNumber: 15,
    name: 'Cosmic Convergence',
    startPos: Offset(0.08, 0.15),
    exitPos: Offset(0.92, 0.85),
    starPositions: List.generate(6, (i) {
      final angle = (i / 6) * 2 * pi;
      final r = 0.12;
      return Offset(0.5 + cos(angle) * r, 0.5 + sin(angle) * r);
    }),
    wells: List.generate(8, (i) {
      final angle = (i / 8) * 2 * pi;
      final r = 0.28;
      final t = i / 8;
      return (
        pos: Offset(0.5 + cos(angle) * r, 0.5 + sin(angle) * r),
        strength: 1.8 + sin(i * 1.5) * 0.5,
        visualRadius: 24,
        color: Color.lerp(const Color(0xFFFF6B35), const Color(0xFF7C4DFF), t)!,
        glowColor: Color.lerp(const Color(0xFFFF9800), const Color(0xFFB388FF), t)!,
      );
    }),
    blackHolePositions: [
      Offset(0.5, 0.5),
    ],
    bgColor: Color(0xFF0A0A1A),
    accentColor: Color(0xFFFFD700),
  ),
];

// ══════════════════════════════════════════════════════════════
// GAME STATE
// ══════════════════════════════════════════════════════════════

class CosmicGameState {
  GameStatus status = GameStatus.menu;
  int currentLevel = 0;
  int maxUnlockedLevel = 0;
  int score = 0;
  int levelScore = 0;
  int highScore = 0;
  int starsCollected = 0;
  int totalStarsInLevel = 0;
  int timesThrusted = 0;

  late Ship ship;
  List<GravityWell> wells = [];
  List<BlackHole> blackHoles = [];
  List<Star> stars = [];
  Portal? portal;
  List<CosmoParticle> particles = [];

  Size gameSize = Size.zero;
  double animTime = 0;
  double thrustAnimTime = 0;
  bool levelComplete = false;

  // Input
  double? touchX, touchY;
  bool dragging = false;

  // Stats
  double timeInLevel = 0;
  int thrustCount = 0;

  final double maxSpeed = 600;
  final double thrustForce = 800;
  final double damping = 0.995;
  final double collectRadius = 18;

  void init(Size size, int levelIndex) {
    gameSize = size;
    currentLevel = levelIndex;
    status = GameStatus.playing;
    _buildLevel(levelIndex);
  }

  void _buildLevel(int index) {
    if (index < 0 || index >= cosmicLevels.length) return;

    final def = cosmicLevels[index];
    final sx = def.startPos.dx * gameSize.width;
    final sy = def.startPos.dy * gameSize.height;
    ship = Ship(position: Offset(sx, sy));

    wells = def.wells.map((w) => GravityWell(
      position: Offset(w.pos.dx * gameSize.width, w.pos.dy * gameSize.height),
      strength: w.strength,
      visualRadius: w.visualRadius,
      color: w.color,
      glowColor: w.glowColor,
    )).toList();

    blackHoles = def.blackHolePositions.map((p) => BlackHole(
      position: Offset(p.dx * gameSize.width, p.dy * gameSize.height),
    )).toList();

    stars = def.starPositions.map((p) => Star(
      position: Offset(p.dx * gameSize.width, p.dy * gameSize.height),
    )).toList();

    portal = Portal(
      position: Offset(def.exitPos.dx * gameSize.width, def.exitPos.dy * gameSize.height),
    );

    totalStarsInLevel = stars.length;
    starsCollected = 0;
    levelScore = 0;
    timeInLevel = 0;
    thrustCount = 0;
    levelComplete = false;
    particles.clear();
    animTime = 0;
    thrustAnimTime = 0;

    // Spawn ambient particles
    for (int i = 0; i < 15; i++) {
      particles.add(CosmoParticle(
        x: Random().nextDouble() * gameSize.width,
        y: Random().nextDouble() * gameSize.height,
        vx: (Random().nextDouble() - 0.5) * 5,
        vy: (Random().nextDouble() - 0.5) * 5,
        maxLifetime: 2 + Random().nextDouble() * 3,
        radius: 0.5 + Random().nextDouble() * 1.5,
        color: Colors.white.withOpacity(0.3),
      ));
    }
  }

  void update(double dt) {
    if (status != GameStatus.playing) return;
    animTime += dt;

    if (levelComplete) return;

    timeInLevel += dt;

    // Apply thrust
    if (dragging && touchX != null && touchY != null) {
      final dx = touchX! - ship.position.dx;
      final dy = touchY! - ship.position.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > 10) {
        final normalizedDx = dx / dist;
        final normalizedDy = dy / dist;
        // Apply thrust with a cap
        final thrust = thrustForce * dt;
        ship.velocity += Offset(normalizedDx * thrust, normalizedDy * thrust);
        thrustAnimTime = animTime;
        thrustCount++;
      }
    }

    // Apply gravity from wells
    for (final well in wells) {
      final force = well.getForce(ship.position, 1.0);
      ship.velocity += force * dt;
    }

    // Apply black hole gravity
    for (final hole in blackHoles) {
      final force = hole.getForce(ship.position, 1.0);
      ship.velocity += force * dt;
    }

    // Damping
    ship.velocity *= damping;

    // Cap speed
    final speed = ship.velocity.distance;
    if (speed > maxSpeed) {
      ship.velocity = ship.velocity / speed * maxSpeed;
    }

    // Update position
    ship.position += ship.velocity * dt;

    // Screen boundaries (bounce)
    if (ship.position.dx < 5) {
      ship.position = Offset(5, ship.position.dy);
      ship.velocity = Offset(-ship.velocity.dx * 0.5, ship.velocity.dy);
    }
    if (ship.position.dx > gameSize.width - 5) {
      ship.position = Offset(gameSize.width - 5, ship.position.dy);
      ship.velocity = Offset(-ship.velocity.dx * 0.5, ship.velocity.dy);
    }
    if (ship.position.dy < 5) {
      ship.position = Offset(ship.position.dx, 5);
      ship.velocity = Offset(ship.velocity.dx, -ship.velocity.dy * 0.5);
    }
    if (ship.position.dy > gameSize.height - 5) {
      ship.position = Offset(ship.position.dx, gameSize.height - 5);
      ship.velocity = Offset(ship.velocity.dx, -ship.velocity.dy * 0.5);
    }

    // Update trail
    ship.updateTrail();

    // Check black hole consumption
    for (final hole in blackHoles) {
      if (hole.consumes(ship.position)) {
        _shipDestroyed();
        return;
      }
    }

    // Check star collection
    for (final star in stars) {
      if (star.checkCollection(ship.position, collectRadius)) {
        starsCollected++;
        star.animTime = animTime;
        levelScore += 100 + (starsCollected * 25);
        _spawnStarBurst(star.position);
      }
    }

    // Portal activation
    if (portal != null) {
      portal!.active = starsCollected >= totalStarsInLevel;
      if (portal!.checkReached(ship.position)) {
        _levelComplete();
      }
    }

    // Update ambient particles
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.dead);

    // Spawn new ambient particles
    if (particles.length < 20 && Random().nextDouble() < 0.02) {
      particles.add(CosmoParticle(
        x: Random().nextDouble() * gameSize.width,
        y: Random().nextDouble() * gameSize.height,
        vx: (Random().nextDouble() - 0.5) * 5,
        vy: (Random().nextDouble() - 0.5) * 5,
        maxLifetime: 2 + Random().nextDouble() * 3,
        radius: 0.5 + Random().nextDouble() * 1.5,
        color: Colors.white.withOpacity(0.2),
      ));
    }
  }

  void _levelComplete() {
    levelComplete = true;
    score += levelScore;
    if (score > highScore) highScore = score;
    ship.reachedPortal = true;
    _spawnPortalBurst();

    Future.delayed(const Duration(milliseconds: 500), () {
      status = GameStatus.levelComplete;
    });
  }

  void _shipDestroyed() {
    ship.alive = false;
    _spawnExplosion(ship.position);
    score = (score * 0.8).round(); // Penalty
    if (score > highScore) highScore = score;

    Future.delayed(const Duration(milliseconds: 1200), () {
      status = GameStatus.gameOver;
    });
  }

  void _spawnStarBurst(Offset pos) {
    for (int i = 0; i < 12; i++) {
      final angle = Random().nextDouble() * 2 * pi;
      final speed = 30 + Random().nextDouble() * 80;
      particles.add(CosmoParticle(
        x: pos.dx,
        y: pos.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.6 + Random().nextDouble() * 0.4,
        radius: 2 + Random().nextDouble() * 2,
        color: const Color(0xFFFFD700),
      ));
    }
  }

  void _spawnExplosion(Offset pos) {
    for (int i = 0; i < 30; i++) {
      final angle = Random().nextDouble() * 2 * pi;
      final speed = 50 + Random().nextDouble() * 150;
      final colors = [const Color(0xFFFF1744), const Color(0xFFFF6B35), const Color(0xFFFFAB00)];
      particles.add(CosmoParticle(
        x: pos.dx,
        y: pos.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.8 + Random().nextDouble() * 0.5,
        radius: 2 + Random().nextDouble() * 3,
        color: colors[Random().nextInt(colors.length)],
      ));
    }
  }

  void _spawnPortalBurst() {
    final pos = portal!.position;
    for (int i = 0; i < 25; i++) {
      final angle = Random().nextDouble() * 2 * pi;
      final speed = 30 + Random().nextDouble() * 100;
      particles.add(CosmoParticle(
        x: pos.dx,
        y: pos.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 1.0 + Random().nextDouble() * 0.5,
        radius: 2 + Random().nextDouble() * 2,
        color: const Color(0xFF00E5FF),
      ));
    }
  }

  void handleDragStart(double x, double y) {
    touchX = x;
    touchY = y;
    dragging = true;
  }

  void handleDragMove(double x, double y) {
    touchX = x;
    touchY = y;
  }

  void handleDragEnd() {
    dragging = false;
    touchX = null;
    touchY = null;
  }
}
