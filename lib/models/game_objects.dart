import 'dart:math';
import 'dart:ui';
import '../core/constants.dart';

// ========================================================
// PARTICLE - Enhanced with trails and effects
// ========================================================

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  List<Offset> trail;
  bool isShielded;
  double lifeTime;

  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    List<Offset>? trail,
    this.isShielded = false,
    this.lifeTime = 0,
  }) : trail = trail ?? [];

  void updateTrail() {
    trail.add(position);
    if (trail.length > GameConstants.maxTrailLength) {
      trail.removeAt(0);
    }
  }

  void clearTrail() {
    trail.clear();
  }

  Particle copyWith({
    Offset? position,
    Offset? velocity,
    double? radius,
    List<Offset>? trail,
    bool? isShielded,
    double? lifeTime,
  }) {
    return Particle(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      radius: radius ?? this.radius,
      trail: trail ?? List.from(this.trail),
      isShielded: isShielded ?? this.isShielded,
      lifeTime: lifeTime ?? this.lifeTime,
    );
  }
}

// ========================================================
// GOAL MARKER - Collection targets
// ========================================================

class GoalMarker {
  Offset position;
  int value;
  bool collected;
  double pulsePhase;
  double attractionStrength; // For magnet powerup

  GoalMarker({
    required this.position,
    required this.value,
    this.collected = false,
    this.pulsePhase = 0,
    this.attractionStrength = 0,
  });

  bool checkCollection(Offset particlePos) {
    return (particlePos - position).distance < GameConstants.goalCollectionRadius;
  }

  void update(double dt) {
    pulsePhase += dt * 3; // Pulsing animation
    if (pulsePhase > 2 * pi) pulsePhase -= 2 * pi;
  }
}

// ========================================================
// BASE GAME OBJECT - Polymorphic base class
// ========================================================

abstract class GameObject {
  Offset position;
  double radius;
  ObjectType type;
  double animationPhase;

  GameObject({
    required this.position,
    required this.radius,
    required this.type,
    this.animationPhase = 0,
  });

  // Calculate force applied to a particle
  Offset calculateForce(Particle particle);

  // Update object state
  void update(double dt);

  // Check if object should affect the particle
  bool isInRange(Particle particle) {
    return (particle.position - position).distance < radius * 3;
  }
}

// ========================================================
// GRAVITY WELL - Standard attractor
// ========================================================

class GravityWell extends GameObject {
  double strength;

  GravityWell({
    required super.position,
    super.radius = 20,
    this.strength = GameConstants.baseGravityStrength,
  }) : super(type: ObjectType.gravityWell);

  @override
  Offset calculateForce(Particle particle) {
    final direction = position - particle.position;
    final distance = direction.distance.clamp(10.0, double.infinity);
    final forceMagnitude = strength / (distance * distance);
    return direction / distance * forceMagnitude;
  }

  @override
  void update(double dt) {
    animationPhase += dt * 2;
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
  }
}

// ========================================================
// REPULSION ZONE - Pushes particles away
// ========================================================

class RepulsionZone extends GameObject {
  double width;
  double height;
  double strength;

  RepulsionZone({
    required super.position,
    required this.width,
    required this.height,
    this.strength = GameConstants.repulsionStrength,
  }) : super(radius: max(width, height) / 2, type: ObjectType.repulsionZone);

  bool contains(Offset point) {
    return point.dx >= position.dx &&
        point.dx <= position.dx + width &&
        point.dy >= position.dy &&
        point.dy <= position.dy + height;
  }

  @override
  Offset calculateForce(Particle particle) {
    if (!contains(particle.position)) return Offset.zero;

    final center = Offset(position.dx + width / 2, position.dy + height / 2);
    final displacement = particle.position - center;
    final distFromCenter = displacement.distance;

    if (distFromCenter < 5) return Offset.zero;

    final forceMagnitude =
        strength / (1 + (distFromCenter - 5).clamp(0, 20) * 0.05);
    return displacement / distFromCenter * forceMagnitude;
  }

  @override
  void update(double dt) {
    animationPhase += dt;
  }
}

// ========================================================
// ORBITING OBJECT - Circles around a point
// ========================================================

class OrbitingObject extends GameObject {
  Offset center;
  double orbitRadius;
  double angularVelocity;
  double currentAngle;
  double attractionStrength;

  OrbitingObject({
    required this.center,
    required this.orbitRadius,
    this.angularVelocity = 1.5,
    this.currentAngle = 0,
    this.attractionStrength = 1.0,
  }) : super(
          position: center +
              Offset(cos(0) * orbitRadius, sin(0) * orbitRadius),
          radius: 15,
          type: ObjectType.orbitingObject,
        );

  @override
  void update(double dt) {
    currentAngle += angularVelocity * dt;
    if (currentAngle > 2 * pi) currentAngle -= 2 * pi;
    position = center +
        Offset(cos(currentAngle) * orbitRadius, sin(currentAngle) * orbitRadius);
    animationPhase = currentAngle;
  }

  @override
  Offset calculateForce(Particle particle) {
    final direction = position - particle.position;
    final distance = direction.distance.clamp(10.0, double.infinity);
    return direction / distance * (attractionStrength / (distance * distance));
  }
}

// ========================================================
// PULSING OBJECT - Strength oscillates
// ========================================================

class PulsingObject extends GameObject {
  double baseStrength;
  double pulseAmplitude;
  double pulseFrequency;
  double _currentStrength;

  PulsingObject({
    required super.position,
    super.radius = 25,
    this.baseStrength = 2.0,
    this.pulseAmplitude = 1.5,
    this.pulseFrequency = 2.0,
  })  : _currentStrength = baseStrength,
        super(type: ObjectType.pulsingObject);

  double get currentStrength => _currentStrength;

  @override
  void update(double dt) {
    animationPhase += dt * pulseFrequency;
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
    _currentStrength = baseStrength + sin(animationPhase) * pulseAmplitude;
  }

  @override
  Offset calculateForce(Particle particle) {
    final direction = position - particle.position;
    final distance = direction.distance.clamp(10.0, double.infinity);
    return direction / distance * (_currentStrength / (distance * distance));
  }
}

// ========================================================
// TELEPORTER - Linked pair transport
// ========================================================

class Teleporter extends GameObject {
  Teleporter? linkedTeleporter;
  double cooldownTimer;
  static const double cooldownDuration = 0.5;

  Teleporter({
    required super.position,
    super.radius = 30,
    this.linkedTeleporter,
  })  : cooldownTimer = 0,
        super(type: ObjectType.teleporter);

  void linkTo(Teleporter other) {
    linkedTeleporter = other;
    other.linkedTeleporter = this;
  }

  bool canTeleport() => cooldownTimer <= 0 && linkedTeleporter != null;

  void triggerCooldown() {
    cooldownTimer = cooldownDuration;
    linkedTeleporter?.cooldownTimer = cooldownDuration;
  }

  @override
  void update(double dt) {
    if (cooldownTimer > 0) cooldownTimer -= dt;
    animationPhase += dt * 3;
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
  }

  @override
  Offset calculateForce(Particle particle) {
    // Teleporters don't apply force, they teleport
    return Offset.zero;
  }

  bool shouldTeleport(Particle particle) {
    return canTeleport() &&
        (particle.position - position).distance < radius;
  }

  Offset getTeleportDestination() {
    if (linkedTeleporter == null) return position;
    // Offset slightly to prevent instant re-teleport
    return linkedTeleporter!.position + const Offset(35, 0);
  }
}

// ========================================================
// SPLITTER - Duplicates particles
// ========================================================

class Splitter extends GameObject {
  double cooldownTimer;
  int maxSplits;
  int splitCount;
  static const double cooldownDuration = 2.0;

  Splitter({
    required super.position,
    super.radius = 25,
    this.maxSplits = 3,
  })  : cooldownTimer = 0,
        splitCount = 0,
        super(type: ObjectType.splitter);

  bool canSplit() => cooldownTimer <= 0 && splitCount < maxSplits;

  void triggerSplit() {
    cooldownTimer = cooldownDuration;
    splitCount++;
  }

  void resetSplits() {
    splitCount = 0;
  }

  @override
  void update(double dt) {
    if (cooldownTimer > 0) cooldownTimer -= dt;
    animationPhase += dt * 2;
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
  }

  @override
  Offset calculateForce(Particle particle) {
    return Offset.zero; // Splitters don't apply force
  }

  bool shouldSplit(Particle particle) {
    return canSplit() && (particle.position - position).distance < radius;
  }

  Particle createSplitParticle(Particle original) {
    final random = Random();
    final angleOffset = (random.nextDouble() - 0.5) * pi / 2;
    final speed = original.velocity.distance;
    final newAngle = atan2(original.velocity.dy, original.velocity.dx) + angleOffset;

    return Particle(
      position: original.position + Offset(cos(newAngle) * 10, sin(newAngle) * 10),
      velocity: Offset(cos(newAngle) * speed, sin(newAngle) * speed),
      radius: original.radius * 0.8,
      isShielded: original.isShielded,
    );
  }
}

// ========================================================
// MAGNETIC FIELD - Directional force
// ========================================================

class MagneticField extends GameObject {
  Offset direction; // Normalized direction
  double strength;
  double width;
  double height;

  MagneticField({
    required super.position,
    required this.direction,
    required this.width,
    required this.height,
    this.strength = 2.0,
  }) : super(radius: max(width, height) / 2, type: ObjectType.magneticField);

  bool contains(Offset point) {
    return point.dx >= position.dx &&
        point.dx <= position.dx + width &&
        point.dy >= position.dy &&
        point.dy <= position.dy + height;
  }

  @override
  void update(double dt) {
    animationPhase += dt;
  }

  @override
  Offset calculateForce(Particle particle) {
    if (!contains(particle.position)) return Offset.zero;
    return direction * strength;
  }
}

// ========================================================
// BLACK HOLE - Destroys particles (hazard)
// ========================================================

class BlackHole extends GameObject {
  double eventHorizonRadius;
  double attractionStrength;

  BlackHole({
    required super.position,
    super.radius = 40,
    this.eventHorizonRadius = 15,
    this.attractionStrength = 4.0,
  }) : super(type: ObjectType.blackHole);

  @override
  void update(double dt) {
    animationPhase += dt * 5; // Fast rotation
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
  }

  @override
  Offset calculateForce(Particle particle) {
    final direction = position - particle.position;
    final distance = direction.distance.clamp(5.0, double.infinity);
    // Stronger attraction that increases rapidly
    return direction / distance * (attractionStrength / (distance * 0.5));
  }

  bool shouldDestroy(Particle particle) {
    if (particle.isShielded) return false;
    return (particle.position - position).distance < eventHorizonRadius;
  }
}

// ========================================================
// POWERUP - Collectible power enhancements
// ========================================================

class Powerup {
  Offset position;
  PowerupType type;
  double duration;
  bool collected;
  double animationPhase;
  double lifeTime;
  static const double maxLifeTime = 10.0;

  Powerup({
    required this.position,
    required this.type,
    required this.duration,
    this.collected = false,
    this.animationPhase = 0,
    this.lifeTime = 0,
  });

  void update(double dt) {
    animationPhase += dt * 4;
    if (animationPhase > 2 * pi) animationPhase -= 2 * pi;
    lifeTime += dt;
  }

  bool isExpired() => lifeTime >= maxLifeTime;

  bool checkCollection(Offset particlePos) {
    return (particlePos - position).distance < GameConstants.powerupCollectionRadius;
  }

  static double getDuration(PowerupType type) {
    switch (type) {
      case PowerupType.shield:
        return 5.0;
      case PowerupType.multiplier:
        return 10.0;
      case PowerupType.slowMotion:
        return 5.0;
      case PowerupType.magnet:
        return 8.0;
      case PowerupType.particleBurst:
        return 0.0; // Instant effect
    }
  }

  static String getName(PowerupType type) {
    switch (type) {
      case PowerupType.shield:
        return 'Shield';
      case PowerupType.multiplier:
        return '2x Score';
      case PowerupType.slowMotion:
        return 'Slow Mo';
      case PowerupType.magnet:
        return 'Magnet';
      case PowerupType.particleBurst:
        return 'Burst';
    }
  }

  static Color getColor(PowerupType type) {
    switch (type) {
      case PowerupType.shield:
        return const Color(0xFF64FFDA);
      case PowerupType.multiplier:
        return const Color(0xFFFFD700);
      case PowerupType.slowMotion:
        return const Color(0xFF00BFFF);
      case PowerupType.magnet:
        return const Color(0xFFFF69B4);
      case PowerupType.particleBurst:
        return const Color(0xFF00FF00);
    }
  }
}
