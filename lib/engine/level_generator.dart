import 'dart:math';
import 'dart:ui';
import '../core/constants.dart';
import '../models/game_objects.dart';

// ========================================================
// LEVEL GENERATOR - Procedural Level Creation
// ========================================================

class LevelGenerator {
  final Random _random = Random();

  LevelData generateLevel(int level, Size gameSize) {
    final availableObjects = DifficultyScaling.getAvailableObjects(level);
    final speedMultiplier = DifficultyScaling.getSpeedMultiplier(level);

    // Generate gravity wells
    final gravityWells = _generateGravityWells(level, gameSize);

    // Generate repulsion zones
    final repulsionZones = _generateRepulsionZones(level, gameSize, availableObjects);

    // Generate special objects based on level
    final orbitingObjects = _generateOrbitingObjects(level, gameSize, availableObjects);
    final pulsingObjects = _generatePulsingObjects(level, gameSize, availableObjects);
    final teleporters = _generateTeleporters(level, gameSize, availableObjects);
    final splitters = _generateSplitters(level, gameSize, availableObjects);
    final magneticFields = _generateMagneticFields(level, gameSize, availableObjects);
    final blackHoles = _generateBlackHoles(level, gameSize, availableObjects);

    // Generate goals
    final goals = _generateGoals(level, gameSize);

    // Generate particles
    final particles = _generateParticles(level, gameSize);

    // Background color shifts with level
    final backgroundColor = _getBackgroundColor(level);

    return LevelData(
      level: level,
      gravityWells: gravityWells,
      repulsionZones: repulsionZones,
      orbitingObjects: orbitingObjects,
      pulsingObjects: pulsingObjects,
      teleporters: teleporters,
      splitters: splitters,
      magneticFields: magneticFields,
      blackHoles: blackHoles,
      goals: goals,
      particles: particles,
      backgroundColor: backgroundColor,
      speedMultiplier: speedMultiplier,
    );
  }

  List<GravityWell> _generateGravityWells(int level, Size gameSize) {
    final count = DifficultyScaling.getGravityWellCount(level);
    final wells = <GravityWell>[];

    for (int i = 0; i < count; i++) {
      // Distribute wells across the screen with some randomness
      final sectionWidth = gameSize.width / count;
      final x = sectionWidth * i +
          _random.nextDouble() * sectionWidth * 0.6 +
          sectionWidth * 0.2;
      final y = gameSize.height * 0.15 +
          _random.nextDouble() * gameSize.height * 0.5;

      // Strength increases slightly with level
      final strength =
          GameConstants.baseGravityStrength * (1 + level * 0.02).clamp(1.0, 2.0);

      wells.add(GravityWell(
        position: Offset(x, y),
        radius: 18 + _random.nextDouble() * 8,
        strength: strength,
      ));
    }

    return wells;
  }

  List<RepulsionZone> _generateRepulsionZones(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.repulsionZone)) return [];

    final count = ((level - 2) ~/ 3).clamp(0, 4);
    final zones = <RepulsionZone>[];

    for (int i = 0; i < count; i++) {
      final width = gameSize.width * (0.1 + _random.nextDouble() * 0.15);
      final height = gameSize.height * (0.08 + _random.nextDouble() * 0.12);

      zones.add(RepulsionZone(
        position: Offset(
          _random.nextDouble() * (gameSize.width - width),
          _random.nextDouble() * (gameSize.height - height) * 0.7 +
              gameSize.height * 0.1,
        ),
        width: width,
        height: height,
        strength: GameConstants.repulsionStrength * (1 + level * 0.01),
      ));
    }

    return zones;
  }

  List<OrbitingObject> _generateOrbitingObjects(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.orbitingObject)) return [];

    final count = ((level - 4) ~/ 5).clamp(0, 3);
    final objects = <OrbitingObject>[];

    for (int i = 0; i < count; i++) {
      final center = Offset(
        gameSize.width * (0.2 + _random.nextDouble() * 0.6),
        gameSize.height * (0.2 + _random.nextDouble() * 0.5),
      );

      objects.add(OrbitingObject(
        center: center,
        orbitRadius: 40 + _random.nextDouble() * 40,
        angularVelocity: (0.8 + _random.nextDouble() * 1.0) *
            (_random.nextBool() ? 1 : -1),
        currentAngle: _random.nextDouble() * 2 * pi,
        attractionStrength: 0.8 + level * 0.02,
      ));
    }

    return objects;
  }

  List<PulsingObject> _generatePulsingObjects(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.pulsingObject)) return [];

    final count = ((level - 7) ~/ 6).clamp(0, 3);
    final objects = <PulsingObject>[];

    for (int i = 0; i < count; i++) {
      objects.add(PulsingObject(
        position: Offset(
          gameSize.width * (0.15 + _random.nextDouble() * 0.7),
          gameSize.height * (0.15 + _random.nextDouble() * 0.55),
        ),
        radius: 22 + _random.nextDouble() * 10,
        baseStrength: 1.5 + level * 0.03,
        pulseAmplitude: 1.0 + level * 0.02,
        pulseFrequency: 1.5 + _random.nextDouble() * 1.5,
      ));
    }

    return objects;
  }

  List<Teleporter> _generateTeleporters(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.teleporter)) return [];

    final pairCount = ((level - 11) ~/ 8).clamp(0, 2);
    final teleporters = <Teleporter>[];

    for (int i = 0; i < pairCount; i++) {
      // Create linked pairs
      final t1 = Teleporter(
        position: Offset(
          gameSize.width * (0.1 + _random.nextDouble() * 0.35),
          gameSize.height * (0.15 + _random.nextDouble() * 0.6),
        ),
        radius: 28,
      );

      final t2 = Teleporter(
        position: Offset(
          gameSize.width * (0.55 + _random.nextDouble() * 0.35),
          gameSize.height * (0.15 + _random.nextDouble() * 0.6),
        ),
        radius: 28,
      );

      t1.linkTo(t2);
      teleporters.addAll([t1, t2]);
    }

    return teleporters;
  }

  List<Splitter> _generateSplitters(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.splitter)) return [];

    final count = ((level - 14) ~/ 10).clamp(0, 2);
    final splitters = <Splitter>[];

    for (int i = 0; i < count; i++) {
      splitters.add(Splitter(
        position: Offset(
          gameSize.width * (0.2 + _random.nextDouble() * 0.6),
          gameSize.height * (0.2 + _random.nextDouble() * 0.5),
        ),
        radius: 25,
        maxSplits: 3 + (level ~/ 20),
      ));
    }

    return splitters;
  }

  List<MagneticField> _generateMagneticFields(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.magneticField)) return [];

    final count = ((level - 19) ~/ 12).clamp(0, 2);
    final fields = <MagneticField>[];

    final directions = [
      const Offset(1, 0), // Right
      const Offset(-1, 0), // Left
      const Offset(0, 1), // Down
      const Offset(0, -1), // Up
    ];

    for (int i = 0; i < count; i++) {
      final width = gameSize.width * (0.15 + _random.nextDouble() * 0.15);
      final height = gameSize.height * (0.1 + _random.nextDouble() * 0.1);

      fields.add(MagneticField(
        position: Offset(
          _random.nextDouble() * (gameSize.width - width),
          _random.nextDouble() * (gameSize.height - height) * 0.6 +
              gameSize.height * 0.15,
        ),
        direction: directions[_random.nextInt(directions.length)],
        width: width,
        height: height,
        strength: 1.5 + level * 0.02,
      ));
    }

    return fields;
  }

  List<BlackHole> _generateBlackHoles(
      int level, Size gameSize, List<ObjectType> available) {
    if (!available.contains(ObjectType.blackHole)) return [];

    final count = ((level - 24) ~/ 15).clamp(0, 2);
    final holes = <BlackHole>[];

    for (int i = 0; i < count; i++) {
      holes.add(BlackHole(
        position: Offset(
          gameSize.width * (0.2 + _random.nextDouble() * 0.6),
          gameSize.height * (0.2 + _random.nextDouble() * 0.5),
        ),
        radius: 35 + _random.nextDouble() * 15,
        eventHorizonRadius: 12 + level * 0.1,
        attractionStrength: 3.0 + level * 0.03,
      ));
    }

    return holes;
  }

  List<GoalMarker> _generateGoals(int level, Size gameSize) {
    final count = DifficultyScaling.getGoalCount(level);
    final goals = <GoalMarker>[];
    const margin = 50.0;

    for (int i = 0; i < count; i++) {
      goals.add(GoalMarker(
        position: Offset(
          margin + _random.nextDouble() * (gameSize.width - margin * 2),
          margin + _random.nextDouble() * (gameSize.height - margin * 2),
        ),
        value: GameConstants.baseGoalValue + level * 2,
        pulsePhase: _random.nextDouble() * 2 * pi,
      ));
    }

    return goals;
  }

  List<Particle> _generateParticles(int level, Size gameSize) {
    final count = DifficultyScaling.getParticleCount(level);
    final particles = <Particle>[];
    const margin = 30.0;

    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        position: Offset(
          margin + _random.nextDouble() * (gameSize.width - margin * 2),
          margin + _random.nextDouble() * (gameSize.height - margin * 2),
        ),
        velocity: Offset(
              (_random.nextDouble() - 0.5) * 2,
              (_random.nextDouble() - 0.5) * 2,
            ) *
            3,
        radius: GameConstants.minParticleRadius +
            _random.nextDouble() *
                (GameConstants.maxParticleRadius - GameConstants.minParticleRadius),
      ));
    }

    return particles;
  }

  Color _getBackgroundColor(int level) {
    // Cycle through color palettes as levels progress
    final hue = (level * 15) % 360;
    final h = hue / 360.0;
    final s = 0.3;
    final l = 0.08;
    final a = 1.0;

    // Simple HSL to RGB conversion
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h * 6) % 2 - 1).abs());
    final m = l - c / 2;

    double r, g, b;
    if (h < 1/6) {
      r = c; g = x; b = 0;
    } else if (h < 2/6) {
      r = x; g = c; b = 0;
    } else if (h < 3/6) {
      r = 0; g = c; b = x;
    } else if (h < 4/6) {
      r = 0; g = x; b = c;
    } else if (h < 5/6) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }

    return Color.fromRGBO(
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
      a,
    );
  }
}

// ========================================================
// LEVEL DATA - Container for generated level
// ========================================================

class LevelData {
  final int level;
  final List<GravityWell> gravityWells;
  final List<RepulsionZone> repulsionZones;
  final List<OrbitingObject> orbitingObjects;
  final List<PulsingObject> pulsingObjects;
  final List<Teleporter> teleporters;
  final List<Splitter> splitters;
  final List<MagneticField> magneticFields;
  final List<BlackHole> blackHoles;
  final List<GoalMarker> goals;
  final List<Particle> particles;
  final Color backgroundColor;
  final double speedMultiplier;

  LevelData({
    required this.level,
    required this.gravityWells,
    required this.repulsionZones,
    required this.orbitingObjects,
    required this.pulsingObjects,
    required this.teleporters,
    required this.splitters,
    required this.magneticFields,
    required this.blackHoles,
    required this.goals,
    required this.particles,
    required this.backgroundColor,
    required this.speedMultiplier,
  });

  // Get all game objects for iteration
  List<GameObject> get allObjects => [
        ...gravityWells,
        ...repulsionZones,
        ...orbitingObjects,
        ...pulsingObjects,
        ...teleporters,
        ...splitters,
        ...magneticFields,
        ...blackHoles,
      ];

  // Check which object types are present
  Set<String> get presentObjectTypes {
    final types = <String>{};
    if (orbitingObjects.isNotEmpty) types.add('orbitingObject');
    if (pulsingObjects.isNotEmpty) types.add('pulsingObject');
    if (teleporters.isNotEmpty) types.add('teleporter');
    if (splitters.isNotEmpty) types.add('splitter');
    if (magneticFields.isNotEmpty) types.add('magneticField');
    if (blackHoles.isNotEmpty) types.add('blackHole');
    return types;
  }
}
